data "azurerm_client_config" "current" {}

resource "random_uuid" "demo_api_reader_role_id" {}
resource "random_uuid" "demo_api_writer_role_id" {}
resource "random_uuid" "demo_api_read_scope_id" {}
resource "random_uuid" "demo_api_write_scope_id" {}

resource "azuread_application" "demo_api" {
  display_name = "Demo API"
  owners       = [data.azurerm_client_config.current.object_id]

  app_role {
    id                   = random_uuid.demo_api_reader_role_id.result
    allowed_member_types = ["User"]
    description          = "Allow read access to the Demo API"
    display_name         = "Reader"
    value                = "Reader"
  }

  app_role {
    id                   = random_uuid.demo_api_writer_role_id.result
    allowed_member_types = ["User"]
    description          = "Allow write access to the Demo API"
    display_name         = "Writer"
    value                = "Writer"
  }

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Demo API read access"
      admin_consent_display_name = "Demo API read access"
      id                         = random_uuid.demo_api_read_scope_id.result
      value                      = "read"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Demo API write access"
      admin_consent_display_name = "Demo API write access"
      id                         = random_uuid.demo_api_write_scope_id.result
      value                      = "write"
    }
  }
}

resource "azuread_application_identifier_uri" "app_uri" {
  application_id = azuread_application.demo_api.id
  identifier_uri = "api://${azuread_application.demo_api.client_id}"
}

resource "azuread_service_principal" "demo_api_service_principal" {
  client_id = azuread_application.demo_api.client_id
}

output "demo_api" {
  value = {
    id        = azuread_application.demo_api.id
    object_id = azuread_service_principal.demo_api_service_principal.object_id
  }
}

output "demo_api_reader_role" {
  value = {
    id   = random_uuid.demo_api_reader_role_id.result
    name = "Reader"
  }
}

output "demo_api_writer_role" {
  value = {
    id   = random_uuid.demo_api_writer_role_id.result
    name = "Writer"
  }
}

output "demo_api_read_scope" {
  value = {
    id   = random_uuid.demo_api_read_scope_id.result
    name = "${azuread_application_identifier_uri.app_uri.identifier_uri}/read"
  }
}

output "demo_api_write_scope" {
  value = {
    id   = random_uuid.demo_api_write_scope_id.result
    name = "${azuread_application_identifier_uri.app_uri.identifier_uri}/write"
  }
}

