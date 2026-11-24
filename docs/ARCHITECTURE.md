# Architecture Decision Records (ADR)

## ADR-001: Internal Virtual Network Mode for Azure API Management (AI Gateway)

### Context
Generative AI workloads in enterprise environments require fronting public LLM endpoints with policy controls while preventing any direct public inbound ingress.

### Decision
Deploy **Azure API Management in Internal Virtual Network mode** (`virtual_network_type = "Internal"`):
- **Zero Public IP:** APIM receives a private IP address within `snet-apim-gateway` (10.100.2.0/24).
- **Private DNS Integration:** Client microservices resolve the gateway via private DNS zones.

---

## ADR-002: Token Throttling vs. Request Rate Limiting

### Context
Traditional API gateways throttle requests by count (requests per second). LLM endpoints incur cost and computational load primarily based on **token consumption** (prompt + completion tokens), not raw request count.

### Decision
Implement **Token-based Throttling** using APIM's `<azure-openai-token-limit>`:
- Throttles consumers dynamically based on Tokens Per Minute (TPM).
- Emits response headers (`x-ai-remaining-tokens`) so client SDKs can throttle gracefully before hitting hard limits.

---

## ADR-003: Key Vault SKU Selection (Standard vs Premium HSM)

### Context
Azure Key Vault offers Standard (software key isolation) and Premium (hardware HSM FIPS 140-2 Level 3).

### Decision
Deploy **Standard SKU** with Customer-Managed Keys (CMK) and private endpoint integration:
- Standard SKU provides full encryption-at-rest with customer-controlled keys and automated key rotation at negligible baseline cost.
- Dedicated Managed HSM is deferred until multi-tenant hardware compliance certification is formally mandated.

---

## ADR-004: AzureRM Provider v5 Modernization & Schema Alignment

### Context
Upgrading the AzureRM Terraform Provider from v4.x to v5.11+ introduced breaking API schema changes and deprecations across core landing zone resources:
1. `azurerm_private_dns_zone_virtual_network_link`: The arguments `resource_group_name` and `private_dns_zone_name` were deprecated and replaced by the consolidated `private_dns_zone_id`.
2. `azurerm_storage_account`: The boolean attribute `public_network_access_enabled` was replaced by the enum-style string `public_network_access = "Disabled"` / `"Enabled"`.
3. Azure Storage naming constraints enforce alphanumeric-only lowercase strings (no hyphens), causing deployments with hyphenated prefixes (e.g. `sks-ai`) to fail validation (`stsks-aidev01`).
4. Subnet definitions with redundant empty `service_endpoints` declarations created noise alongside strict Private Endpoint network policy enforcement.

### Decision
1. **Consolidated DNS Zone Linking**: Migrate all Private DNS VNet link resources across AI Search, Key Vault, Azure OpenAI, and Blob Storage modules to use `private_dns_zone_id = azurerm_private_dns_zone.<zone>.id`.
2. **Modernized Storage Public Access**: Configure `public_network_access = "Disabled"` on `azurerm_storage_account` in alignment with AzureRM v5 specifications.
3. **Storage Account Naming Sanitization**: Standardize the storage account naming convention to `lower("st${var.environment}0123")` to guarantee conformance with Azure's 3-24 character alphanumeric constraint.
4. **Streamlined Subnet Schema**: Clean up unused service endpoint declarations in favor of explicit Private Endpoints and NSG micro-segmentation.

### Consequences
- Clean static validation (`terraform validate`) and execution planning (`terraform plan: 30 to add, 0 to change, 0 to destroy`).
- Elimination of deprecation warnings across provider upgrades.
- Consistent configuration across both `dev` and `prod` environments.

---

## ADR-005: Zero-Trust APIM Subnet Security, ADLS Gen2 Constraints & Resilience Architecture

### Context
Executing `terraform apply` against live Azure subscriptions surfaced runtime platform constraints:
1. **APIM Internal VNet Requirement**: Deploying Azure API Management with `virtual_network_type = "Internal"` mandates that the target subnet has an associated Network Security Group (NSG) with explicit rules for Microsoft control plane management (port 3443) and Azure Load Balancer health probes (port 6390). Missing NSG association resulted in `NetworkSecurityGroupNotFound`.
2. **ADLS Gen2 Versioning Incompatibility**: Storage accounts with Hierarchical Namespace enabled (`is_hns_enabled = true`) for Data Lake Gen2 do not support Blob Versioning (`versioning_enabled = true`), triggering ARM error: "`versioning_enabled` can't be true when `is_hns_enabled` is true".
3. **Azure OpenAI Model Lifecycle**: Version `2024-05-13` of `gpt-4o` reached deprecating state in Azure Cognitive Services, failing new deployments with `ServiceModelDeprecating`.
4. **Regional Capacity Fluctuations**: Provisioning Azure AI Search in `eastus2` hit regional compute exhaustion (`InsufficientResourcesAvailable`).

### Decision
1. **APIM-Compliant NSG Rules & Association**:
   - Implemented mandatory inbound rules: Port 3443 for `ApiManagement` control plane, Port 6390 for `AzureLoadBalancer`, and Port 443 for client communication.
   - Configured outbound dependencies for `Storage`, `AzureActiveDirectory`, and `AzureMonitor`.
   - Associated NSG to all spoke subnets via `azurerm_subnet_network_security_group_association` and linked `subnet_ids` output dependency.
2. **ADLS Gen2 Storage Optimization**:
   - Disabled blob versioning on the ADLS Gen2 filesystem while preserving 14-day soft-delete retention policies.
3. **OpenAI Model Lifecycle Modernization**:
   - Upgraded default `gpt-4o` model version to `2024-08-06` (GA with Structured Outputs support).
4. **AI Search Regional Resilience**:
   - Decoupled Search deployment region via `search_location` (defaulting to `eastus`) while retaining Private Link endpoint termination in the primary workload VNet (`eastus2`).



