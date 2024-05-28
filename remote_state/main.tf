provider "azurerm" {
  features {}
}

module "setup_remote_state" {
  source                    = "../modules/setup_remote_state"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
}

output "remote_backend_config" {
  value = module.setup_remote_state.remote_backend_config
  sensitive = true
}

