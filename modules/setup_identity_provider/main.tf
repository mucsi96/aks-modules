data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "random_uuid" "admin_role_id" {}

resource "random_uuid" "user_role_id" {}

resource "azuread_application" "token_agent" {
  display_name = "Token Agent"
  owners       = [data.azurerm_client_config.current.object_id]

  app_role {
    id                   = random_uuid.admin_role_id.result
    allowed_member_types = ["User"]
    description          = "Admin role"
    display_name         = "Admin"
    value                = "admin"
  }

  app_role {
    id                   = random_uuid.user_role_id.result
    allowed_member_types = ["User"]
    description          = "User role"
    display_name         = "User"
    value                = "user"
  }

  web {
    redirect_uris = ["http://localhost:8080/callback", "https://auth.auth-tools.home/callback"]
  }
}

resource "azuread_service_principal" "token_agent_service_principal" {
  client_id = azuread_application.token_agent.client_id
}

resource "azuread_application_password" "password" {
  application_id = azuread_application.token_agent.id
}

resource "azuread_app_role_assignment" "main_user_app_role_assignment" {
  app_role_id         = random_uuid.admin_role_id.result
  principal_object_id = data.azurerm_client_config.current.object_id
  resource_object_id  = azuread_service_principal.token_agent_service_principal.object_id
}
