variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "apim_name" {
  type = string
}

variable "publisher_name" {
  type    = string
  default = "Sanjeev Singh Enterprise Cloud Architecture"
}

variable "publisher_email" {
  type    = string
  default = "sanjeevsinghred@gmail.com"
}

variable "sku_name" {
  type    = string
  default = "Developer_1"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for internal APIM virtual network injection."
}

variable "openai_endpoint" {
  type        = string
  description = "Target Azure OpenAI backend endpoint."
}

variable "tags" {
  type    = map(string)
  default = {}
}
