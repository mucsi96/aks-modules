output "remote_backend_config" {
  value     = <<EOT
terraform {
    backend "azurerm" {
        storage_account_name = "${azurerm_storage_account.remote_state_storage_account.name}"
        container_name       = "${azurerm_storage_container.remote_state_storage_container.name}"
        key                  = "terraform.tfstate"
        sas_token            = "${data.azurerm_storage_account_sas.remote_state_sas_token.sas}"
    }
}
EOT
  sensitive = true
}
