variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint."
}

variable "vnet_id" {
  type        = string
  description = "VNet ID for private DNS zone link."
}

variable "model_deployments" {
  type = map(object({
    model_format  = string
    model_name    = string
    model_version = string
    sku_name      = string
    sku_capacity  = number
  }))
  default = {
    "gpt-4o" = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o"
      model_version = "2024-05-13"
      sku_name      = "GlobalStandard"
      sku_capacity  = 30
    },
    "text-embedding-3-large" = {
      model_format  = "OpenAI"
      model_name    = "text-embedding-3-large"
      model_version = "1"
      sku_name      = "Standard"
      sku_capacity  = 50
    }
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
