terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "=3.2.2"
    }
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "null_resource" "pull_kube_admin_config" {
  triggers = {
    kube_admin_config = data.azurerm_kubernetes_cluster.aks.kube_config_raw
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${dirname(var.k8s_admin_config_path)}
      echo '${data.azurerm_kubernetes_cluster.aks.kube_config_raw}' > ${var.k8s_admin_config_path}
    EOT
  }
}
