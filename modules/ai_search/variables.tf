variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "search_location" {
  type        = string
  description = "Azure region for the Search service. If null, defaults to var.location."
  default     = null
}

variable "search_service_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "sku" {
  type    = string
  default = "standard"
}

variable "tags" {
  type    = map(string)
  default = {}
}
