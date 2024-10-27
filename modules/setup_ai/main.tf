resource "azurerm_ai_services" "ai_services" {
  name                = "ai-account"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "openai_deployment" {
  name                 = "openai-deployment"
  cognitive_account_id = azurerm_ai_services.ai_services.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-08-06"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 5
  }
}
