variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "prefix" {
  type    = string
  default = "sks-ai"
}

variable "search_location" {
  type        = string
  description = "Azure region for the AI Search service (allows fallback when eastus2 is out of capacity)."
  default     = "eastus"
}
