data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "azuread_application" "token_agent" {
  display_name            = "Token Agent"
  owners                  = [data.azurerm_client_config.current.object_id]

  web {
    redirect_uris = ["http://localhost:8080/callback", "https://auth.${var.hostname}/callback"]
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
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
  sensitive = true
}
