resource "azuread_application_pre_authorized" "traefik_dashboard_access" {
  application_id       = module.setup_ingress_controller.app.id
  authorized_client_id = module.setup_identity_provider.app.client_id

  permission_ids = [
    module.setup_ingress_controller.dashboard_access_scope.id
  ]
}

resource "azuread_application_pre_authorized" "demo_api_access" {
  application_id       = azuread_application.demo_api.id
  authorized_client_id = module.setup_identity_provider.app.client_id

  permission_ids = [
    random_uuid.demo_api_read_scope_id.result,
    random_uuid.demo_api_write_scope_id.result
  ]
}

resource "azuread_app_role_assignment" "allow_admin_user_access_traefik_dashboard" {
  app_role_id         = module.setup_ingress_controller.dashboard_access_role.id
  principal_object_id = data.azurerm_client_config.current.object_id
  resource_object_id  = module.setup_ingress_controller.app.object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_read_demo_api" {
  app_role_id         = random_uuid.demo_api_reader_role_id.result
  principal_object_id = data.azurerm_client_config.current.object_id
  resource_object_id  = azuread_service_principal.demo_api_service_principal.object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_write_demo_api" {
  app_role_id         = random_uuid.demo_api_writer_role_id.result
  principal_object_id = data.azurerm_client_config.current.object_id
  resource_object_id  = azuread_service_principal.demo_api_service_principal.object_id
}

resource "azuread_app_role_assignment" "allow_test_user_read_demo_api" {
  app_role_id         = random_uuid.demo_api_reader_role_id.result
  principal_object_id = module.setup_identity_provider.test_user.object_id
  resource_object_id  = azuread_service_principal.demo_api_service_principal.object_id
}
