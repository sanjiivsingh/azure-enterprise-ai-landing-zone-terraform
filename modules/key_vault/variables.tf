variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Private Endpoint."
}

variable "vnet_id" {
  type        = string
  description = "VNet ID for the Private DNS link."
}

variable "tags" {
  type    = map(string)
  default = {}
}
