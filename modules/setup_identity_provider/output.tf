output "client_id" {
  value     = azuread_application.token_agent.client_id
  sensitive = true
}

output "client_secret" {
  value     = azuread_application_password.password.value
  sensitive = true
}

output "issuer" {
  value     = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
  sensitive = true
}

output "test_user_email" {
  value     = azuread_user.test_user.user_principal_name
  sensitive = true
}

output "test_user_password" {
  value     = random_password.test_user_password.result
  sensitive = true
}
