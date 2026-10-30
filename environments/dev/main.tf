locals {
  common_tags = {
    Environment        = var.environment
    Architect          = "Sanjeev Singh"
    Contact            = "https://github.com/sanjiivsingh"
    Portfolio          = "https://sanjeevsingh.oneps.in"
    InfrastructureType = "Enterprise AI Landing Zone"
    Governance         = "CAF for AI & CIS Benchmark"
    ManagedBy          = "Terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = "vnet-${var.prefix}-${var.environment}"
  address_space       = ["10.100.0.0/16"]

  subnets = {
    "snet-ai-private-endpoints" = {
      address_prefixes                          = ["10.100.1.0/24"]
      private_endpoint_network_policies_enabled = true
    },
    "snet-apim-gateway" = {
      address_prefixes                          = ["10.100.2.0/24"]
      private_endpoint_network_policies_enabled = false
    },
    "snet-app-workload" = {
      address_prefixes                          = ["10.100.3.0/24"]
      private_endpoint_network_policies_enabled = true
    }
  }

  tags = local.common_tags
}

module "telemetry" {
  source              = "../../modules/telemetry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name_prefix         = "${var.prefix}-${var.environment}"
  tags                = local.common_tags
}

module "key_vault" {
  source              = "../../modules/key_vault"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  key_vault_name      = "kv-${var.prefix}-${var.environment}-01"
  subnet_id           = module.network.subnet_ids["snet-ai-private-endpoints"]
  vnet_id             = module.network.vnet_id
  tags                = local.common_tags
}

module "openai" {
  source              = "../../modules/openai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  account_name        = "oai-${var.prefix}-${var.environment}-01"
  subnet_id           = module.network.subnet_ids["snet-ai-private-endpoints"]
  vnet_id             = module.network.vnet_id
  tags                = local.common_tags
}

module "ai_search" {
  source              = "../../modules/ai_search"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  search_service_name = "srch-${var.prefix}-${var.environment}-01"
  subnet_id           = module.network.subnet_ids["snet-ai-private-endpoints"]
  vnet_id             = module.network.vnet_id
  tags                = local.common_tags
}

module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.location
  storage_account_name = "st${var.prefix}${var.environment}01"
  subnet_id            = module.network.subnet_ids["snet-ai-private-endpoints"]
  vnet_id              = module.network.vnet_id
  tags                 = local.common_tags
}

module "ai_gateway" {
  source              = "../../modules/ai_gateway_apim"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  apim_name           = "apim-${var.prefix}-${var.environment}-01"
  subnet_id           = module.network.subnet_ids["snet-apim-gateway"]
  openai_endpoint     = module.openai.endpoint
  publisher_email     = "sanjeevsinghred@gmail.com"
  tags                = local.common_tags
}
