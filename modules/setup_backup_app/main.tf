data "azurerm_storage_account" "storage_account" {
  name                = var.azure_storage_account_name
  resource_group_name = var.azure_storage_account_resource_group_name
}

module "create_backup_namespace" {
  source                    = "../create_app_namespace"
  azure_resource_group_name = var.azure_resource_group_name
  k8s_namespace             = "backup"
}

module "setup_backup_api" {
  source = "../register_api"
  owner  = var.owner

  display_name = "Backup API"
  roles        = ["DatabaseBackupsReader", "DatabaseBackupCreator", "DatabaseBackupCleaner", "DatabaseBackupRestorer", "DatabaseBackupDownloader"]
  scopes       = ["readBackups", "createBackup", "cleanupBackups", "restoreBackup", "downloadBackup"]

  k8s_oidc_issuer_url           = var.k8s_oidc_issuer_url
  k8s_service_account_namespace = "backup"
  k8s_service_account_name      = "postgres-azure-backup"
}

module "setup_backup_spa" {
  source = "../register_spa"
  owner  = var.owner

  display_name  = "Backup SPA"
  redirect_uris = ["https://backup.${var.hostname}/auth", "http://localhost:4200/auth"]

  api_id        = module.setup_backup_api.application_id
  api_client_id = module.setup_backup_api.client_id
  api_scope_ids = module.setup_backup_api.scope_ids
}

resource "azurerm_role_assignment" "allow_backup_api_to_read_storage_account_keys" {
  scope                = data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = module.setup_backup_api.resource_object_id
}

resource "azurerm_role_assignment" "allow_backup_api_to_write_storage_account" {
  scope                = data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.setup_backup_api.resource_object_id
}
