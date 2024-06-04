resource "random_password" "test_user_password" {
  length = 16
}

data "azuread_domains" "aad_domains" {}

resource "azuread_user" "test_user" {
  user_principal_name         = "test.user@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  display_name                = "Test User"
  mail_nickname               = "test.user"
  password                    = random_password.test_user_password.result
  disable_password_expiration = true
  disable_strong_password     = true
  force_password_change       = false
}

resource "azuread_app_role_assignment" "test_user_admin_app_role_assignment" {
  app_role_id         = azuread_application_app_role.user_role.role_id
  principal_object_id = azuread_user.test_user.object_id
  resource_object_id  = azuread_service_principal.identity_provider_service_principal.object_id
}
