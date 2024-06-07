data "azuread_domains" "aad_domains" {
  only_default = true
}

locals {
  ad_domain = data.azuread_domains.aad_domains.domains[0].domain_name
}

resource "random_password" "test_user_password" {
  length = 16
}

resource "azuread_user" "test_user" {
  user_principal_name         = "test.user@${local.ad_domain}"
  display_name                = "Test User"
  mail_nickname               = "test.user"
  password                    = random_password.test_user_password.result
  disable_password_expiration = true
  disable_strong_password     = true
  force_password_change       = false
}

resource "azuread_app_role_assignment" "test_user_app_role_assignment" {
  app_role_id         = random_uuid.user_role_id.result
  principal_object_id = azuread_user.test_user.object_id
  resource_object_id  = azuread_service_principal.token_agent_service_principal.object_id
}
