output "k8s_admin_config" {
  value = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw
  sensitive = true
}
