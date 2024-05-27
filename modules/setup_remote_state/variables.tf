variable "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "azure_location" {
  description = "The Azure location to deploy resources"
  type        = string
  default     = "centralindia"
}

variable "remote_state_directory" {
  description = "The directory to store the remote state"
  type        = string
}

