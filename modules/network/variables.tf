variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region for network resources."
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network."
  default     = "vnet-ai-spoke"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the spoke virtual network."
  default     = ["10.100.0.0/16"]
}

variable "subnets" {
  type = map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = optional(bool, true)
    service_endpoints                         = optional(list(string), [])
  }))
  description = "Subnets configuration map."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
