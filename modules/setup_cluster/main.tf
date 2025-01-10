terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.14.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  address_space       = ["10.0.0.0/12"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.azure_resource_group_name
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "ibari-${var.azure_resource_group_name}"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "log_analytics_solution" {
  solution_name         = "ContainerInsights"
  location              = var.azure_location
  resource_group_name   = var.azure_resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                              = var.azure_resource_group_name
  location                          = var.azure_location
  resource_group_name               = var.azure_resource_group_name
  dns_prefix                        = var.azure_resource_group_name # 
  role_based_access_control_enabled = true
  # see https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#oidc-issuer
  # see https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection
  # see https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery
  oidc_issuer_enabled = true
  # see https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview
  # see https://azure.github.io/azure-workload-identity/docs/
  workload_identity_enabled = true
  kubernetes_version        = var.azure_k8s_version
  node_os_upgrade_channel   = "NodeImage"
  automatic_upgrade_channel = "node-image"

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
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  }
}

resource "azurerm_role_assignment" "aks_principal_as_subnet_network_contributor" {
  scope                = azurerm_subnet.subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.azure_resource_group_name
  resource_group_name = azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
  location            = var.azure_location
  allocation_method   = "Static"
  sku                 = "Standard"
}
