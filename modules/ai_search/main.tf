resource "azurerm_search_service" "this" {
  name                          = var.search_service_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  public_network_access_enabled = false
  semantic_search_sku           = "free"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "search" {
  name                = "privatelink.search.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "search" {
  name                  = "link-search-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.search.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "search" {
  name                = "pe-${var.search_service_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.search_service_name}"
    private_connection_resource_id = azurerm_search_service.this.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  private_dns_zone_group {
    name                 = "search-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.search.id]
  }
}
