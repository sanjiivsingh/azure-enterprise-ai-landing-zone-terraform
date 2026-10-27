output "id" {
  value = azurerm_cognitive_account.openai.id
}

output "endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "principal_id" {
  value = azurerm_cognitive_account.openai.identity[0].principal_id
}
