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
  value     = module.setup_cluster.k8s_admin_config
  sensitive = true
}

# data "azurerm_key_vault_secret" "dns_zone" {
#   name = local.azure_resource_group_name
#   key_vault_id  = "dns-zone"
# }

# data "azurerm_key_vault_secret" "ip_range" {
#   name = local.azure_resource_group_name
#   key_vault_id  = "ip-range"
# }

# module "setup_ingress_controller" {
#   source                    = "./modules/setup_ingress_controller"
#   azure_resource_group_name = local.azure_resource_group_name
#   azure_location            = local.azure_location
#   dns_zone                  = data.azurerm_key_vault_secret.dns_zone.value
#   k8s_admin_config_path     = module.setup_cluster.k8s_admin_config_path
#   traefik_chart_version     = local.traefik_chart_version
#   ip_range                  = data.azurerm_key_vault_secret.ip_range.value
# }
