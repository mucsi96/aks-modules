terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }
  }
}

resource "azurerm_dns_zone" "dns_zone" {
  resource_group_name = var.azure_resource_group_name
  name                = var.dns_zone
}
