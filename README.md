# 🤖 Azure Enterprise AI & GenAI Landing Zone (Terraform)

[![CI/CD Pipeline](https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/sanjiivsingh/azure-enterprise-ai-landing-zone-terraform/actions/workflows/ci-cd.yml)
[![Terraform 1.9+](https://img.shields.io/badge/Terraform-1.9+-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure Provider v4+](https://img.shields.io/badge/AzureRM-v4.0+-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![DevSecOps Checkov](https://img.shields.io/badge/Security-Checkov_SAST-10B981?style=for-the-badge&logo=securityscorecard&logoColor=white)](https://www.checkov.io/)
[![Status: Statically Validated](https://img.shields.io/badge/Status-Statically_Validated-10B981?style=for-the-badge)](docs/EVIDENCE.md)
[![Compliance: CIS Azure](https://img.shields.io/badge/Compliance-CIS_Azure_Mapped-0284C7?style=for-the-badge)](COMPLIANCE.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

> **Reference Architecture · Statically Validated**  
> Enterprise Generative AI Landing Zone engineered on Microsoft Azure using modular Terraform. Implements a Zero-Trust perimeter, private networking, Azure OpenAI model deployments (GPT-4o & Embeddings), API Management as an internal AI Gateway with token rate limiting, Azure AI Search vector database for Enterprise RAG, and automated DevSecOps pipelines. Detailed verification logs are provided in [docs/EVIDENCE.md](docs/EVIDENCE.md) and architectural decisions in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 🏛️ Architecture Overview

```mermaid
flowchart TD
    subgraph Hub["🏢 Transit Hub Network (10.0.0.0/16)"]
        FW["🔥 Azure Firewall Egress"]
        BASTION["🛡️ Azure Bastion & VPN"]
        DNS["🌐 Private DNS Resolver Zone"]
        LOGS["📊 Log Analytics & App Insights"]
    end

    subgraph Spoke["🤖 AI Workload Spoke Network (10.100.0.0/16)"]
        APIM["⚡ AI Gateway (Azure APIM Internal)<br/>• Token TPM/RPM Rate Limiting<br/>• Managed Identity Backend Auth<br/>• Multi-Region Retry & Failover"]
        
        OAI["🧠 Azure OpenAI (Private Endpoint)<br/>• GPT-4o Model Deployment<br/>• text-embedding-3-large<br/>• Public Access: 100% Disabled"]
        
        SEARCH["🔍 Azure AI Search (Vector RAG)<br/>• Hybrid Semantic Search<br/>• Private Link Endpoint"]
        
        KV["🔒 Azure Key Vault (Standard CMK)<br/>• Managed Identity RBAC<br/>• Customer-Managed Keys (CMK)"]
        
        LAKE["📦 Data Lake Storage Gen2<br/>• Grounding Document Repository<br/>• Blob Private Endpoint"]
    end

    App["💻 Enterprise Client & Microservices"] -->|Private VNet Link| APIM
    APIM -->|Managed Identity Auth| OAI
    APIM -->|Query & Context| SEARCH
    SEARCH -->|Grounding Chunks| LAKE
    OAI -.->|Telemetry & Tokens| LOGS
    APIM -.->|Latency & Errors| LOGS
    KV -.->|CMK Encryption Keys| OAI

    style Hub fill:#0b1328,stroke:#0284c7,stroke-width:2px,color:#fff
    style Spoke fill:#070d1e,stroke:#10b981,stroke-width:2px,color:#fff
    style APIM fill:#1e1b4b,stroke:#818cf8,stroke-width:1.5px,color:#fff
    style OAI fill:#082f49,stroke:#38bdf8,stroke-width:1.5px,color:#fff
    style SEARCH fill:#451a03,stroke:#f59e0b,stroke-width:1.5px,color:#fff
    style KV fill:#064e3b,stroke:#34d399,stroke-width:1.5px,color:#fff
    style LAKE fill:#1f2937,stroke:#94a3b8,stroke-width:1.5px,color:#fff
```

---

## 🎯 Key Architectural Pillars

### 1. 🛡️ Zero-Trust Network Perimeter (100% Private Endpoints)
* **Zero Public Exposure**: `public_network_access_enabled = false` enforced across Azure OpenAI, Azure AI Search, Azure Key Vault, and Data Lake Storage.
* **Micro-Segmented Subnets**:
  * `snet-ai-private-endpoints` (`10.100.1.0/24`): Dedicated isolated network space for Private Links.
  * `snet-apim-gateway` (`10.100.2.0/24`): Internal VNet injection for API Management.
  * `snet-app-workload` (`10.100.3.0/24`): Application tier consumption.
* **Private DNS Zones**: Seamless internal FQDN resolution via `privatelink.openai.azure.com`, `privatelink.search.windows.net`, `privatelink.vaultcore.azure.net`, and `privatelink.blob.core.windows.net`.

### 2. ⚡ AI Gateway via Azure API Management (APIM)
* **Token Rate Limiting**: Enforces strict Tokens-Per-Minute (TPM) and Requests-Per-Minute (RPM) quotas per consumer application to mitigate unexpected cost spikes and DoS attacks.
* **Zero Long-Lived Keys**: Consumer apps authenticate via Entra ID; APIM forwards requests to Azure OpenAI using its **System-Assigned Managed Identity**.
* **Circuit Retry & Fallback**: Automated retry on HTTP 429 rate limit or 5xx backend errors with exponential backoff.
* **Semantic Caching Architecture**: Policy XML supports response caching; requires an external Azure Cache for Redis connection in production.

### 3. 🧠 Azure OpenAI Model Deployments
* **GPT-4o**: Multimodal generative AI model provisioned with configurable capacity allocations.
* **text-embedding-3-large**: High-dimensional semantic embeddings for enterprise document retrieval.

### 4. 🔍 Azure AI Search (Vector Database for Enterprise RAG)
* Enterprise RAG (Retrieval-Augmented Generation) vector index pairing vector representations with keyword matching.
* Backed by Azure Data Lake Gen2 storage with private endpoints.

### 5. 🔒 Key Vault & Banking-Grade Governance
* **Key Vault Standard SKU**: Customer-Managed Key (CMK) envelope encryption; soft-delete and purge protection enabled; access restricted via Azure RBAC.
* **Compliance Mapping**: Documented in [COMPLIANCE.md](COMPLIANCE.md) against CIS Azure Foundations Benchmark v2.0 and NIST SP 800-53 controls.

---

## 📂 Repository Structure

```text
azure-enterprise-ai-landing-zone-terraform/
├── architectures/
│   └── ai-landing-zone-architecture.svg
├── modules/
│   ├── network/                      # Spoke VNet, Subnets, NSGs & Route Tables
│   ├── openai/                       # Azure OpenAI, Model Deployments & Private Endpoint
│   ├── ai_gateway_apim/              # APIM AI Gateway with XML policy integration
│   │   └── policies/
│   │       └── ai-gateway-policy.xml # Token Rate Limiting & Managed Identity XML Policies
│   ├── ai_search/                    # Azure AI Search Vector Store & Private Endpoint
│   ├── key_vault/                    # Azure Key Vault Standard & Private Endpoint
│   ├── storage/                      # Azure Storage Data Lake Gen2 for RAG Grounding
│   └── telemetry/                    # Log Analytics & Application Insights
├── environments/
│   ├── dev/                          # Development Environment Root Module
│   └── prod/                         # Production Environment Root Module
├── docs/
│   ├── ARCHITECTURE.md               # Architectural Decision Records (ADRs)
│   └── EVIDENCE.md                   # Static validation outputs & cost estimates
└── COMPLIANCE.md                     # CIS Azure Benchmark & NIST SP 800-53 Mapping
```

---

## 🚀 Local Initialization & Validation

```bash
cd environments/dev
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -out=ai-landing-zone.tfplan
```

### Resource Teardown

```bash
terraform destroy -auto-approve
```

---

## 👨‍💻 Author & Cloud Architect

**Sanjeev Singh**  
*Senior Azure Cloud Architect & DevSecOps Platform Engineer*  
* 🌐 **Portfolio**: [sanjeevsingh.oneps.in](https://sanjeevsingh.oneps.in)  
* 💼 **LinkedIn**: [linkedin.com/in/sanjiivsingh](https://linkedin.com/in/sanjiivsingh)  
* 🐙 **GitHub**: [github.com/sanjiivsingh](https://github.com/sanjiivsingh)

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
