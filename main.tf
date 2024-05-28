module "setup_cluster" {
  source                    = "./modules/setup_cluster"
  azure_resource_group_name = local.azure_resource_group_name
  azure_location            = local.azure_location
  azure_k8s_version         = local.azure_k8s_version
}

module "pull_kube_admin_config" {
  depends_on = [module.setup_cluster]

  source                    = "./modules/pull_kube_admin_config"
  azure_resource_group_name = local.azure_resource_group_name
  k8s_admin_config_path     = ".kube/admin-config"
}
