variable "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "azure_location" {
  description = "The Azure location to deploy resources"
  type        = string
}

variable "hostname" {
  description = "Token agent public hostname"
  type        = string
}

variable "token_agent_version" {
  description = "The version of the Token Agent to deploy"
  type        = number
}

