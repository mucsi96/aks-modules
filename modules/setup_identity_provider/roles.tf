resource "random_uuid" "admin_role_id" {}

resource "azuread_application_app_role" "admin_role" {
  application_id = azuread_application_registration.identity_provider.id
  role_id        = random_uuid.admin_role_id.id

  allowed_member_types = ["User"]
  description          = "Admin role"
  display_name         = "Admin"
  value                = "admin"
}

resource "azuread_app_role_assignment" "test_user_user_app_role_assignment" {
  app_role_id         = azuread_application_app_role.admin_role.role_id
  principal_object_id = data.azurerm_client_config.current.object_id
  resource_object_id  = azuread_service_principal.identity_provider_service_principal.object_id
}

resource "random_uuid" "user_role_id" {}

resource "azuread_application_app_role" "user_role" {
  application_id = azuread_application_registration.identity_provider.id
  role_id        = random_uuid.user_role_id.id

  allowed_member_types = ["User"]
  description          = "User role"
  display_name         = "User"
  value                = "user"
}
