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

data "azurerm_key_vault" "kv" {
  resource_group_name = local.azure_resource_group_name
  name                = local.azure_resource_group_name
}

data "azurerm_key_vault_secret" "dns_zone" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "dns-zone"
}

data "azurerm_key_vault_secret" "ip_range" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "ip-range"
}

module "setup_ingress_controller" {
  depends_on = [module.setup_cluster]

  source                    = "./modules/setup_ingress_controller"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  dns_zone                  = data.azurerm_key_vault_secret.dns_zone.value
  k8s_admin_config_path     = ".kube/admin-config"
  traefik_chart_version     = local.traefik_chart_version
  ip_range                  = data.azurerm_key_vault_secret.ip_range.value
}
