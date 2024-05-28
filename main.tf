provider "azurerm" {
  features {}
}

module "setup_cluster" {
  source                    = "./modules/setup_cluster"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  azure_k8s_version         = local.azure_k8s_version
}

output "k8s_admin_config" {
  value = module.setup_cluster.k8s_admin_config
  sensitive = true
}
