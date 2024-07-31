resource "azuread_application_pre_authorized" "traefik_dashboard_access" {
  application_id       = module.setup_ingress_controller.app.id
  authorized_client_id = module.setup_identity_provider.app.client_id

  permission_ids = [
    module.setup_ingress_controller.dashboard_access_scope.id
  ]
}

resource "azuread_application_pre_authorized" "demo_api_access" {
  application_id       = module.register_demo_api.application_id
  authorized_client_id = module.setup_identity_provider.app.client_id
  permission_ids       = module.register_demo_api.scope_ids
}

resource "azuread_app_role_assignment" "allow_admin_user_access_traefik_dashboard" {
  app_role_id         = module.setup_ingress_controller.dashboard_access_role.id
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.setup_ingress_controller.app.object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_read_demo_api" {
  app_role_id         = module.register_demo_api.roles_ids["Reader"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.register_demo_api.resource_object_id
}

resource "azuread_app_role_assignment" "allow_admin_user_write_demo_api" {
  app_role_id         = module.register_demo_api.roles_ids["Writer"]
  principal_object_id = module.setup_cluster.owner
  resource_object_id  = module.register_demo_api.resource_object_id
}

resource "azuread_app_role_assignment" "allow_test_user_read_demo_api" {
  app_role_id         = module.register_demo_api.roles_ids["Reader"]
  principal_object_id = module.setup_identity_provider.test_user.object_id
  resource_object_id  = module.register_demo_api.resource_object_id
}
