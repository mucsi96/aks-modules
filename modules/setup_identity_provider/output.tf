output "client_id" {
  value     = azuread_application_registration.identity_provider.client_id
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
