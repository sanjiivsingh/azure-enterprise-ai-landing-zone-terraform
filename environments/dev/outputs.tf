output "openai_endpoint" {
  value       = module.openai.endpoint
  description = "Private Azure OpenAI endpoint."
}

output "apim_gateway_url" {
  value       = module.ai_gateway.gateway_url
  description = "Internal APIM AI Gateway URL."
}

output "key_vault_uri" {
  value       = module.key_vault.vault_uri
  description = "Key Vault URI."
}
