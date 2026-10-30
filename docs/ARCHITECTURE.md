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
