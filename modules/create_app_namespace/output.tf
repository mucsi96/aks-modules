output "k8s_user_config" {
  value     = <<EOT
apiVersion: v1
kind: Config
clusters:
  - name: cluster
    cluster:
      server: ${kubernetes_cluster.kube_config.0.host}
      certificate-authority-data: ${kubernetes_cluster.kube_config.0.cluster_ca_certificate}
users:
  - name: user
    user:
      token: ${kuberntest_secret.service_account_secret.0.token}
contexts:
  - name: default
    context:
      cluster: cluster
      name: default
      user: user
current-context: default
EOT
  sensitive = true
}
