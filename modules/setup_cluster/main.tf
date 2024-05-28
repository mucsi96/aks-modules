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

resource "azurerm_virtual_network" "virtual_network" {
  name                = azurerm_resource_group.resource_group.name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/12"]
}

resource "azurerm_subnet" "subnet" {
  name                 = azurerm_resource_group.resource_group.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                              = azurerm_resource_group.resource_group.name
  location                          = azurerm_resource_group.resource_group.location
  resource_group_name               = azurerm_resource_group.resource_group.name
  dns_prefix                        = azurerm_resource_group.resource_group.name
  role_based_access_control_enabled = true
  kubernetes_version                = var.azure_k8s_version
  node_os_channel_upgrade           = "NodeImage"
  automatic_channel_upgrade         = "node-image"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = var.azure_vm_size
    os_disk_size_gb = var.azure_vm_disk_size_gb
    vnet_subnet_id  = azurerm_subnet.subnet.id

    upgrade_settings {
      max_surge = 1
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }
}

resource "azurerm_role_assignment" "aks_principal_as_subnet_network_contributor" {
  scope                = azurerm_subnet.subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
}

resource "azurerm_public_ip" "public_ip" {
  name                = azurerm_resource_group.resource_group.name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
  sku                 = "Basic"
}
