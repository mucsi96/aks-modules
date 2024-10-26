terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.33.0"
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
      version = ">=2.26.0"
    }
  }
}
