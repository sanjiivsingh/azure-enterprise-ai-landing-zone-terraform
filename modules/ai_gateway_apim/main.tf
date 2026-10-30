resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name

  identity {
    type = "SystemAssigned"
  }

  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  tags = var.tags
}

resource "azurerm_api_management_backend" "openai" {
  name                = "openai-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  protocol            = "http"
  url                 = var.openai_endpoint

  description = "Enterprise Azure OpenAI Backend with Private Network Connectivity"
}

resource "azurerm_api_management_policy" "global_ai_policy" {
  api_management_id = azurerm_api_management.apim.id
  xml_content       = file("${path.module}/policies/ai-gateway-policy.xml")

  depends_on = [azurerm_api_management_backend.openai]
}
