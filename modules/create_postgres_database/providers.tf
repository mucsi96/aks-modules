terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">=2.13.2"
    }
  }
}
