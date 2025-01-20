terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.6"
    }

    acme = {
      source  = "vancluever/acme"
      version = ">=2.28.2"
    }
  }
}

provider "random" {}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
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

provider "acme" {
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory" # Staging server
  server_url = "https://acme-v02.api.letsencrypt.org/directory" # Production server
}

module "setup_cluster" {
  source                    = "./modules/setup_cluster"
  azure_resource_group_name = "p05"
  azure_location            = "centralindia"
  azure_k8s_version         = "1.31"
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
  traefik_chart_version = "33.2.1" #https://github.com/traefik/traefik-helm-chart/releases
  ip_range              = data.azurerm_key_vault_secret.ip_range.value
  letsencrypt_email     = data.azurerm_key_vault_secret.letsencrypt_email.value

  depends_on = [module.setup_cluster]
}

module "create_database_namespace" {
  source                    = "./modules/create_app_namespace"
  azure_resource_group_name = module.setup_cluster.resource_group_name
  k8s_namespace             = "db"

  depends_on = [module.setup_ingress_controller]
}

module "create_database" {
  source        = "./modules/create_postgres_database"
  k8s_name      = "db"
  k8s_namespace = module.create_database_namespace.k8s_namespace
  db_name       = "db"
}

module "setup_backup_app" {
  source                    = "./modules/setup_backup_app"
  azure_resource_group_name = module.setup_cluster.resource_group_name
  azure_location            = module.setup_cluster.location
  owner                     = module.setup_cluster.owner
  k8s_oidc_issuer_url       = module.setup_cluster.oidc_issuer_url
  hostname                  = module.setup_ingress_controller.hostname

  azure_storage_account_resource_group_name = "ibari"
  azure_storage_account_name                = "ibari"

  depends_on = [module.setup_ingress_controller]
}

module "create_demo_app_namespace" {
  source                    = "./modules/create_app_namespace"
  azure_resource_group_name = module.setup_cluster.resource_group_name
  k8s_namespace             = "demo"

  depends_on = [module.setup_ingress_controller]
}

module "register_demo_api" {
  source       = "./modules/register_api"
  owner        = module.setup_cluster.owner
  display_name = "Demo API"
  roles        = ["Reader", "Writer"]
  scopes       = ["read", "write"]

  k8s_oidc_issuer_url           = module.setup_cluster.oidc_issuer_url
  k8s_service_account_namespace = "demo"
  k8s_service_account_name      = "demo-api"

  depends_on = [module.setup_ingress_controller]
}

