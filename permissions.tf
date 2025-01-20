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
