terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.6.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">=3.0.2"
    }
  }
}
