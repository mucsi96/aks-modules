terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.2"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.105.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.50.0"
    }
  }
}
