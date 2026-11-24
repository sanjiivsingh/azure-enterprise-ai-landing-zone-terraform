# Verification & Evidence Summary

## 1. Verified CI Workflow Executions (GitHub Actions)

* **Pipeline Name:** DevSecOps AI Landing Zone CI/CD (`.github/workflows/ci-cd.yml`)
* **Latest Passing Run ID:** `40450338890`
* **Direct CI Run URL:** [https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/runs/40450338890](https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/runs/40450338890)
* **Preceding Validated Run:** [https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/runs/40431864943](https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/runs/40431864943)

---

## 2. Static Code Validation Evidence

Command executed:
```bash
cd environments/dev
terraform init -backend=false
terraform validate
```

**Output:**
```text
Success! The configuration is valid.
```

---

## 3. Terraform Plan Execution Evidence

Validation command executed:
```bash
cd environments/dev
terraform plan
```

**Execution Output:**
```text
Plan: 30 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + apim_gateway_url = (known after apply)
  + key_vault_uri    = (known after apply)
  + openai_endpoint  = (known after apply)
```

### Remediated Provider v5 Compatibility Details
- **Private DNS Virtual Network Links**: Updated `azurerm_private_dns_zone_virtual_network_link` across `ai_search`, `key_vault`, `openai`, and `storage` modules to use `private_dns_zone_id` replacing deprecated `resource_group_name` and `private_dns_zone_name`.
- **Storage Account Public Access**: Updated `azurerm_storage_account` to modern `public_network_access = "Disabled"`.
- **Storage Account Naming**: Normalized storage account name to `lower("st${var.environment}0123")` ensuring compliance with Azure alphanumeric-only lowercase rules.
- **Subnet Configuration**: Cleaned unused `service_endpoints` attribute from subnets map to align with Private Endpoint isolation.

---

## 4. Live Runtime Apply Verification & Issue Remediation Log

During initial end-to-end `terraform apply` against Azure, the following platform runtime constraints were identified and resolved:

| Runtime Error from Azure | Root Cause | Architectural Remediation in Code |
| :--- | :--- | :--- |
| `NetworkSecurityGroupNotFound: API Management service deployment into SubnetId ... requires a Network Security Group` | Internal VNet APIM requires an NSG associated with the subnet containing ports 3443 and 6390 | Added `azurerm_subnet_network_security_group_association` for all subnets and configured inbound rules for `ApiManagement` (3443), `AzureLoadBalancer` (6390), HTTPS (443), and outbound service dependencies |
| `versioning_enabled can't be true when is_hns_enabled is true` | Azure Storage does not allow blob versioning on ADLS Gen2 accounts with hierarchical namespace | Removed `versioning_enabled` from `modules/storage/main.tf` while maintaining 14-day soft delete retention |
| `ServiceModelDeprecating: The model 'Format:OpenAI,Name:gpt-4o,Version:2024-05-13' is in deprecating state` | Azure OpenAI deprecated `2024-05-13` for new model deployments | Updated default model version in `modules/openai/variables.tf` to `2024-08-06` |
| `InsufficientResourcesAvailable: The region 'eastus2' is currently out of the resources` | Azure AI Search standard capacity temporarily exhausted in `eastus2` | Decoupled search region via `search_location` variable defaulting to `eastus`, linked over private endpoint to the spoke VNet |

---

## 5. Estimated Infrastructure Cost (Infracost Summary)

| Component | Tier / SKU | Monthly Cost (USD) |
| :--- | :--- | :---: |
| **Azure API Management** | Developer / Standard SKU | ~$50.00 – $279.00 |
| **Azure OpenAI Service** | S0 (Consumption / Token Usage) | Usage based (~$0.005/1k tokens) |
| **Azure AI Search** | Basic / Standard S1 | ~$73.00 |
| **Azure Key Vault** | Standard SKU | ~$0.03 |
| **Storage Account (ADLS Gen2)** | Standard LRS (Hot) | ~$2.00 |
| **Log Analytics Workspace** | Pay-as-you-go | Usage based (~$2.30/GB) |
| **Virtual Network & Private Endpoints** | 4 Private Endpoints | ~$29.20 |
| **Total Base Monthly Est.** | | **~$154.23 – $383.23 / month** |

