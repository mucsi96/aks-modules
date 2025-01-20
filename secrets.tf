resource "azurerm_key_vault_secret" "issuer" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "issuer"
  value        = module.setup_cluster.issuer
}

resource "azurerm_key_vault_secret" "tenant_id" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "tenant-id"
  value        = module.setup_cluster.tenant_id
}

resource "azurerm_key_vault_secret" "k8s_admin_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "k8s-admin-config"
  value        = module.setup_cluster.k8s_admin_config
}

resource "azurerm_key_vault_secret" "hostname" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "hostname"
  value        = module.setup_ingress_controller.hostname
}

resource "azurerm_key_vault_secret" "db_namespace_k8s_user_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "db-namespace-k8s-user-config"
  value        = module.create_database_namespace.k8s_user_config
}

resource "azurerm_key_vault_secret" "demo_namespace_k8s_user_config" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "demo-namespace-k8s-user-config"
  value        = module.create_demo_app_namespace.k8s_user_config
}

resource "azurerm_key_vault_secret" "demo_db_username" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "db-username"
  value        = module.create_database.username
}

resource "azurerm_key_vault_secret" "demo_db_password" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "db-password"
  value        = module.create_database.password
}

resource "azurerm_key_vault_secret" "demo_api_client_id" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "demo-api-client-id"
  value        = module.register_demo_api.client_id
}
