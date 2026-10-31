# Compliance & Security Controls Mapping

This document provides a concrete control mapping between the Terraform configuration and industry security standards (**CIS Microsoft Azure Foundations Benchmark v2.0** and **NIST SP 800-53 Rev 5**).

---

## 1. Zero-Trust Network Perimeter Controls

| Security Standard | Control ID | Control Description | Architectural Implementation in Code |
| :--- | :--- | :--- | :--- |
| **CIS Azure Benchmark** | 5.1.1 | Ensure that Azure Storage Account public network access is disabled | `modules/storage/main.tf`: `public_network_access_enabled = false` with Private Endpoint |
| **CIS Azure Benchmark** | 8.4 | Ensure that Key Vault disables public network access | `modules/key_vault/main.tf`: `public_network_access_enabled = false` with Private Endpoint |
| **CIS Azure Benchmark** | 8.1 | Ensure that Key Vault has soft delete and purge protection enabled | `modules/key_vault/main.tf`: `purge_protection_enabled = true`, `soft_delete_retention_days = 90` |
| **NIST SP 800-53** | AC-3 / SC-7 | Access Enforcement & Boundary Protection | `modules/network/main.tf`: Micro-segmented subnets (`snet-ai-private-endpoints`, `snet-apim-gateway`, `snet-app-workload`) with NSG default-deny rules |
| **NIST SP 800-53** | SC-8 | Transmission Confidentiality and Integrity | `modules/ai_gateway_apim/main.tf`: APIM deployed in `virtual_network_type = "Internal"` with Private DNS zone resolution |

---

## 2. Generative AI Governance & API Controls

| Security Standard | Objective | Implementation Mechanism | Code Reference |
| :--- | :--- | :--- | :--- |
| **AI Gateway Token Control** | Prevent prompt abuse, runaway costs, and DoS attacks | Dynamic TPM/RPM token limits enforced per subscription ID | `modules/ai_gateway_apim/policies/ai-gateway-policy.xml`: `<azure-openai-token-limit>` |
| **Managed Identity Auth** | Passwordless service-to-service communication | Azure Entra Managed Identity eliminating stored connection strings or API keys | `modules/ai_gateway_apim/policies/ai-gateway-policy.xml`: `<authentication-managed-identity>` |
| **Data Boundary Isolation** | Prevent training data exfiltration | Cognitive Services account deployed with zero public internet ingress | `modules/openai/main.tf`: `public_network_access_enabled = false` |
| **Cryptographic Protection** | Customer-Managed Key (CMK) envelope encryption | Key Vault Standard SKU with software-isolated CMK wrapping data keys | `modules/key_vault/main.tf`: `sku_name = "standard"` with private DNS link |

