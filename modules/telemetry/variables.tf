variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for telemetry resource names."
  default     = "ai-platform"
}

variable "retention_in_days" {
  type        = number
  description = "Log Analytics workspace retention in days."
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
