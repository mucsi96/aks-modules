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
  azure_resource_group_name = "p02"
  azure_location            = "centralindia"
  azure_k8s_version         = "1.29.4"
}

data "azurerm_key_vault" "kv" {
  resource_group_name = module.setup_cluster.resource_group_name
  name                = module.setup_cluster.resource_group_name
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
  source                = "./modules/setup_ingress_controller"
  resource_group_name   = module.setup_cluster.resource_group_name
  location              = module.setup_cluster.location
  owner                 = module.setup_cluster.owner
  tenant_id             = module.setup_cluster.tenant_id
  subscription_id       = module.setup_cluster.subscription_id
  dns_zone              = data.azurerm_key_vault_secret.dns_zone.value
  traefik_chart_version = "30.0.0" #https://github.com/traefik/traefik-helm-chart/releases
  ip_range              = data.azurerm_key_vault_secret.ip_range.value
  letsencrypt_email     = data.azurerm_key_vault_secret.letsencrypt_email.value
}

module "setup_identity_provider" {
  depends_on = [module.setup_ingress_controller]

  owner                     = module.setup_cluster.owner
  issuer                    = module.setup_cluster.issuer
  source                    = "./modules/setup_identity_provider"
  azure_resource_group_name = module.setup_cluster.resource_group_name
  azure_location            = module.setup_cluster.location
  hostname                  = "${module.setup_cluster.resource_group_name}.${data.azurerm_key_vault_secret.dns_zone.value}"
  token_agent_version       = 1
}

module "register_demo_api" {
  source       = "./modules/register_api"
  owner        = module.setup_cluster.owner
  display_name = "Demo API"
  roles        = ["Reader", "Writer"]
  scopes       = ["read", "write"]
}

module "create_demo_app_namespace" {
  source                    = "./modules/create_app_namespace"
  azure_resource_group_name = module.setup_cluster.resource_group_name
  k8s_namespace             = "demo"
}

module "create_demo_database" {
  source        = "./modules/create_postgres_database"
  k8s_name      = "demo-db"
  k8s_namespace = module.create_demo_app_namespace.k8s_namespace
  db_name       = "demo"
}
