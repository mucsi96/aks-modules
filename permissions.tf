data "azurerm_storage_account" "storage_account" {
  name                = "ibari"
  resource_group_name = "ibari"
}

data "azurerm_storage_container" "storage_container" {
  name               = "learn-language"
  storage_account_id = data.azurerm_storage_account.storage_account.id
}

/**
 * Backup App
 */
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

/**
 * Learn Language
 */
resource "azurerm_role_assignment" "allow_learn_language_api_to_read_storage_account_keys" {
  scope                = data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = module.setup_learn_language_api.resource_object_id
}

resource "azurerm_role_assignment" "allow_learn_language_api_to_read_and_write_learn_language_storage_container" {
  scope                = data.azurerm_storage_container.storage_container.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.setup_learn_language_api.resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_to_read_learn_language_card_decks" {
  app_role_id         = module.setup_learn_language_api.roles_ids["DeckReader"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_learn_language_api.resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_to_create_learn_language_card_decks" {
  app_role_id         = module.setup_learn_language_api.roles_ids["DeckCreator"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_learn_language_api.resource_object_id
}
