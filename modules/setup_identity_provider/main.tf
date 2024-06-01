terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.50.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }

}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "azuread_application_registration" "identity_provider" {
  display_name            = "Identity Provider"
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = ["All"]
}

resource "azuread_application_redirect_uris" "redirect_uris" {
  application_id = azuread_application_registration.identity_provider.id
  type           = "Web"
  redirect_uris  = ["https://localhost:8080"]
}

resource "azuread_application_password" "password" {
  application_id = azuread_application_registration.identity_provider.id
}


