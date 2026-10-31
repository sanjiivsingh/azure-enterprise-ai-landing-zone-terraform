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

## 3. Estimated Infrastructure Cost (Infracost Summary)

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

