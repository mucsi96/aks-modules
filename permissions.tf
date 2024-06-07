data "azurerm_client_config" "current" {}

data "azuread_domains" "aad_domains" {
  only_default = true
}

locals {
  demo_api_uri = "https://${data.azuread_domains.aad_domains.domains[0].domain_name}/demo-api"
}

resource "azuread_application_pre_authorized" "traefik_dashboard_access" {
  application_id       = module.setup_ingress_controller.app_id
  authorized_client_id = module.setup_identity_provider.client_id

  permission_ids = [
    module.setup_ingress_controller.dashboard_access_scope_id
  ]
}

resource "random_uuid" "demo_api_read_scope" {}
resource "random_uuid" "demo_api_write_scope" {}

resource "azuread_application" "demo_api" {
  display_name    = "Demo API"
  identifier_uris = ["${local.demo_api_uri}"]
  owners          = [data.azurerm_client_config.current.object_id]

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Demo API read access"
      admin_consent_display_name = "Demo API read access"
      id                         = random_uuid.demo_api_read_scope.result
      value                      = "read"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Demo API write access"
      admin_consent_display_name = "Demo API write access"
      id                         = random_uuid.demo_api_write_scope.result
      value                      = "write"
    }
  }
}

resource "azuread_application_pre_authorized" "demo_api_access" {
  application_id       = azuread_application.demo_api.id
  authorized_client_id = module.setup_identity_provider.client_id

  permission_ids = [
    random_uuid.demo_api_read_scope.result,
    random_uuid.demo_api_write_scope.result
  ]
}

resource "azurerm_key_vault_secret" "demo_api_read_scope_id" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "demo-api-read-scope"
  value        = "${local.demo_api_uri}/${random_uuid.demo_api_read_scope.result}"
}

resource "azurerm_key_vault_secret" "demo_api_write_scope_id" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "demo-api-write-scope"
  value        = "${local.demo_api_uri}/${random_uuid.demo_api_write_scope.result}"
}

resource "azurerm_key_vault_secret" "permissions" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "permissions"
  value = jsonencode({
    issuer        = module.setup_identity_provider.issuer,
    client_id     = module.setup_identity_provider.client_id,
    client_secret = module.setup_identity_provider.client_secret,
    api_scopes = [
      {
        scope          = "${local.demo_api_uri}/read"
        required_roles = ["user"]
      },
      {
        scope          = "${local.demo_api_uri}/write"
        required_roles = ["admin"]
      },
      {
        scope          = module.setup_ingress_controller.dashboard_access_scope
        required_roles = ["admin"]
      }
    ]
  })
}
