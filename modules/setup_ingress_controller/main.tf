data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

data "azurerm_public_ip" "public_ip" {
  resource_group_name = data.azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
  name                = var.azure_resource_group_name
}
