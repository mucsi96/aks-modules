variable "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "azure_location" {
  description = "The Azure location to deploy resources"
  type        = string
}

variable "dns_zone" {
  description = "The DNS zone to use for the cluster"
  type        = string
  sensitive   = true
}

variable "traefik_chart_version" {
  description = "The version of the Traefik Helm chart to deploy"
  type        = string
}

variable "ip_range" {
  description = "The IP range to allow traffic from"
  type        = string
  sensitive   = true
}

variable "letsencrypt_email" {
  description = "The email address to use for Let's Encrypt"
  type        = string
  sensitive   = true
}
