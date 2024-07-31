resource "random_uuid" "traefik_dashboard_access_role_id" {}

resource "random_uuid" "traefik_dashboard_access_scope_id" {}

resource "azuread_application" "traefik" {
  display_name = "Traefik"
  owners       = [var.owner]

  app_role {
    id                   = random_uuid.traefik_dashboard_access_role_id.result
    allowed_member_types = ["User"]
    description          = "Allow access to the Traefik Dashboard"
    display_name         = "Dashboard.Viewer"
    value                = "Dashboard.Viewer"
  }

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Access the Traefik Dashboard"
      admin_consent_display_name = "Access the Traefik Dashboard"
      id                         = random_uuid.traefik_dashboard_access_scope_id.result
      value                      = "dashboard-access"
    }
  }
}

resource "azuread_application_identifier_uri" "app_uri" {
  application_id = azuread_application.traefik.id
  identifier_uri = "api://${azuread_application.traefik.client_id}"
}

resource "azuread_service_principal" "token_agent_service_principal" {
  client_id = azuread_application.traefik.client_id
}

output "app" {
  value = {
    id        = azuread_application.traefik.id
    client_id = azuread_application.traefik.client_id
    object_id = azuread_service_principal.token_agent_service_principal.object_id
  }
}

output "dashboard_access_scope" {
  value = {
    id   = random_uuid.traefik_dashboard_access_scope_id.result
    name = "${azuread_application_identifier_uri.app_uri.identifier_uri}/dashboard-access"
  }
}

output "dashboard_access_role" {
  value = {
    id   = random_uuid.traefik_dashboard_access_role_id.result
    name = "Dashboard.Viewer"
  }
}
