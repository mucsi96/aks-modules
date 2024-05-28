terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}

resource "azurerm_storage_account" "remote_state_storage_account" {
  name                     = substr("tfstate${sha1(azurerm_resource_group.resource_group.id)}", 0, 24)
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "remote_state_storage_container" {
  name                 = "terraformstate"
  storage_account_name = azurerm_storage_account.remote_state_storage_account.name
}

data "azurerm_storage_account_sas" "remote_state_sas_token" {
  connection_string = azurerm_storage_account.remote_state_storage_account.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "8640h")

}

