provider "azurerm" {
  features {}
}

module "init" {
  source                    = "../modules/init"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
}
