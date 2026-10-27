variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
