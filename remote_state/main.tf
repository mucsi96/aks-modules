module "setup_remote_state" {
  source                    = "../modules/setup_remote_state"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  remote_state_directory    = ".."
}

