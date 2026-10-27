resource "azurerm_cognitive_account" "openai" {
  name                          = var.account_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  public_network_access_enabled = false
  custom_subdomain_name         = var.account_name

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
  }

  tags = var.tags
}

resource "azurerm_cognitive_deployment" "models" {
  for_each = var.model_deployments

  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.sku_capacity
  }
}

resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = "link-openai-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "openai" {
  name                = "pe-${var.account_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.account_name}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "openai-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai.id]
  }
}
