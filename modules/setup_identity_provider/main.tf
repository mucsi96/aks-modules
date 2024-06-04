data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "azuread_application_registration" "identity_provider" {
  display_name = "Identity Provider"
}

resource "azuread_service_principal" "identity_provider_service_principal" {
  client_id = azuread_application_registration.identity_provider.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_owner" "owner" {
  application_id  = azuread_application_registration.identity_provider.id
  owner_object_id = data.azurerm_client_config.current.object_id
}

resource "azuread_application_identifier_uri" "identifier_uri" {
  application_id = azuread_application_registration.identity_provider.id
  identifier_uri = "https://${data.azuread_domains.aad_domains.domains[0].domain_name}/identity-provider"
}

resource "azuread_application_redirect_uris" "redirect_uris" {
  application_id = azuread_application_registration.identity_provider.id
  type           = "Web"
  redirect_uris  = ["http://localhost:8080/callback", "https://auth.auth-tools.home/callback"]
}

resource "random_uuid" "identity_provider_default_scope_id" {}

resource "azuread_application_permission_scope" "identity_provider_default_scope" {
  application_id             = azuread_application_registration.identity_provider.id
  scope_id                   = random_uuid.identity_provider_default_scope_id.result
  value                      = "default"
  admin_consent_display_name = "Login to the application"
  admin_consent_description  = "Login to the application"
}

resource "azuread_application_api_access" "api_access" {
  application_id = azuread_application_registration.identity_provider.id
  api_client_id  = azuread_application_registration.identity_provider.client_id

  scope_ids = [azuread_application_permission_scope.identity_provider_default_scope.scope_id]
}

resource "azuread_application_password" "password" {
  application_id = azuread_application_registration.identity_provider.id
}
