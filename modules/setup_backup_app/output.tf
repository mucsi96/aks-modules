output "k8s_user_config" {
  value = module.create_backup_namespace.k8s_user_config
}

output "backup_api_client_id" {
  value = module.setup_backup_api.client_id
}

output "backup_spa_client_id" {
  value = module.setup_backup_spa.client_id
}
