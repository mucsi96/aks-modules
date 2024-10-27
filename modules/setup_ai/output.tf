output "endpoint" {
  value = azurerm_ai_services.ai_services.endpoint
}

output "access_key" {
  value = azurerm_ai_services.ai_services.primary_access_key
}

output "api_version" {
  value = "2024-08-01-preview"
}
