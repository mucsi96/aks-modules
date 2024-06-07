provider "random" {}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "kubernetes" {
  host                   = module.setup_cluster.k8s_host
  client_certificate     = module.setup_cluster.k8s_client_certificate
  client_key             = module.setup_cluster.k8s_client_key
  cluster_ca_certificate = module.setup_cluster.k8s_cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.setup_cluster.k8s_host
    client_certificate     = module.setup_cluster.k8s_client_certificate
    client_key             = module.setup_cluster.k8s_client_key
    cluster_ca_certificate = module.setup_cluster.k8s_cluster_ca_certificate
  }
}

module "setup_cluster" {
  source                    = "./modules/setup_cluster"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  azure_k8s_version         = local.azure_k8s_version
}

resource "azurerm_key_vault_secret" "k8s_admin_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "k8s-admin-config"
  value        = module.setup_cluster.k8s_admin_config
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

data "azurerm_key_vault_secret" "letsencrypt_email" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "letsencrypt-email"
}

module "setup_ingress_controller" {
  depends_on = [module.setup_cluster]

  source                    = "./modules/setup_ingress_controller"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  dns_zone                  = data.azurerm_key_vault_secret.dns_zone.value
  traefik_chart_version     = local.traefik_chart_version
  ip_range                  = data.azurerm_key_vault_secret.ip_range.value
  letsencrypt_email         = data.azurerm_key_vault_secret.letsencrypt_email.value
}

resource "azurerm_key_vault_secret" "traefik_dashboard_access_scope_id" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "traefik-dashboard-access-scope"
  value        = module.setup_ingress_controller.dashboard_access_scope
}

module "create_demo_app_namespace" {
  depends_on = [module.setup_cluster]

  source                    = "./modules/create_app_namespace"
  azure_resource_group_name = local.azure_resource_group_name
  k8s_namespace             = "demo"
}

resource "azurerm_key_vault_secret" "demo_namespace_k8s_user_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "demo-namespace-k8s-user-config"
  value        = module.create_demo_app_namespace.k8s_user_config
}

module "setup_identity_provider" {
  source                    = "./modules/setup_identity_provider"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
}

resource "azurerm_key_vault_secret" "test_user_email" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "test-user-email"
  value        = module.setup_identity_provider.test_user_email
}

resource "azurerm_key_vault_secret" "test_user_password" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "test-user-password"
  value        = module.setup_identity_provider.test_user_password
}
