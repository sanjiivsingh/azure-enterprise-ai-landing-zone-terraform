variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
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
