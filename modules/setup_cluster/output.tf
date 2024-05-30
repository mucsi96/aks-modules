output "k8s_admin_config" {
  value     = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw
  sensitive = true
}

output "k8s_host" {
  value     = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.host
  sensitive = true
}

output "k8s_client_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_certificate)
  sensitive = true
}

output "k8s_client_key" {
  value     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.client_key)
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.kubernetes_cluster.kube_config.0.cluster_ca_certificate)
  sensitive = true
}
