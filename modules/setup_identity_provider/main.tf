resource "azuread_application" "token_agent" {
  display_name = "Token Agent"
  owners       = [var.owner]

  web {
    redirect_uris = [
      "http://localhost:8080/callback",
      "https://auth.${var.hostname}/callback"
    ]
  }

  api {
    requested_access_token_version = 2
  }
}

resource "azuread_service_principal" "token_agent_service_principal" {
  client_id = azuread_application.token_agent.client_id
}

resource "azuread_application_password" "password" {
  application_id = azuread_application.token_agent.id
}

output "app" {
  value = {
    id        = azuread_application.token_agent.id
    client_id = azuread_application.token_agent.client_id
    object_id = azuread_service_principal.token_agent_service_principal.object_id
    secret    = azuread_application_password.password.value
  }
  sensitive = true
}
