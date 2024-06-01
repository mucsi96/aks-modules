provider "azurerm" {
  features {}
}

module "init" {
  source                    = "../modules/init"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
}

resource "azurerm_key_vault_secret" "remote_backend_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "remote-backend-config"
  value        = module.setup_cluster.k8s_admin_config
}
