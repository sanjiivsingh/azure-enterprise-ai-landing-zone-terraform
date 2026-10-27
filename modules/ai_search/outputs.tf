output "id" {
  value = azurerm_search_service.this.id
}

output "principal_id" {
  value = azurerm_search_service.this.identity[0].principal_id
}
