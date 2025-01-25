resource "azuread_app_role_assignment" "allow_admin_user_read_backups" {
  app_role_id         = module.setup_backup_app.backup_api_roles_ids["DatabaseBackupsReader"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_backup_app.backup_api_resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_create_backups" {
  app_role_id         = module.setup_backup_app.backup_api_roles_ids["DatabaseBackupCreator"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_backup_app.backup_api_resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_cleanup_backups" {
  app_role_id         = module.setup_backup_app.backup_api_roles_ids["DatabaseBackupCleaner"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_backup_app.backup_api_resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_restore_backups" {
  app_role_id         = module.setup_backup_app.backup_api_roles_ids["DatabaseBackupRestorer"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_backup_app.backup_api_resource_object_id
}
