data "azuread_domains" "aad_domains" {
  only_default = true
}

resource "random_password" "test_user_password" {
  length = 16
}

resource "azuread_user" "test_user" {
  user_principal_name         = "test.user@${data.azuread_domains.aad_domains.domains[0].domain_name}"
  display_name                = "Test User"
  mail_nickname               = "test.user"
  password                    = random_password.test_user_password.result
  disable_password_expiration = true
  disable_strong_password     = true
  force_password_change       = false
}

output "test_user" {
  value = {
    object_id = azuread_user.test_user.object_id
    email     = azuread_user.test_user.user_principal_name
    password = random_password.test_user_password.result
  }
  sensitive = true
}
