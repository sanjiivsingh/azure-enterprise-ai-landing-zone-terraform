output "id" {
  value = azurerm_api_management.apim.id
}

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}

output "principal_id" {
  value = azurerm_api_management.apim.identity[0].principal_id
}
