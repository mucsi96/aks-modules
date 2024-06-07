locals {
  app_uri = "https://${data.azuread_domains.aad_domains.domains[0].domain_name}/traefik"
}

resource "random_uuid" "traefik_dashboard_access_scope_id" {}

resource "azuread_application" "traefik" {
  display_name    = "Traefik"
  identifier_uris = ["${local.app_uri}"]
  owners          = [data.azurerm_client_config.current.object_id]

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
