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

    tls = {
      source = "hashicorp/tls"
      version = ">=4.0.5"
    }

    acme = {
      source = "vancluever/acme"
      version = ">=2.25.0"
    }
  }
}
