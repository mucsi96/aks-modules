resource "azurerm_ai_services" "ai_services" {
  name                = "ai-account"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "S0"
}
