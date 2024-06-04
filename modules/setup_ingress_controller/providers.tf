terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.105.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.30.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.13.2"
    }
  }
}
