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

data "azurerm_public_ip" "public_ip" {
  resource_group_name = var.azure_resource_group_name
  name                = var.azure_resource_group_name
}

resource "azurerm_dns_a_record" "dns_a_record" {
  resource_group_name = var.azure_resource_group_name
  zone_name           = azurerm_dns_zone.dns_zone.name
  name                = "*"
  ttl                 = 300
  records             = [data.azurerm_public_ip.public_ip.ip_address]
}
