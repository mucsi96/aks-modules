terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.105.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
  }
}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.k8s_namespace
    namespace = var.k8s_namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_role" "role" {
  metadata {
    name      = var.k8s_namespace
    namespace = var.k8s_namespace
  }

  rule {
    api_groups = [
      "",
    ]
    resources = [
      "namespaces",
      "configmaps",
      "secrets",
      "services",
      "persistentvolumeclaims",
    ]
    verbs = [
      "get",
      "create",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "apps",
    ]
    resources = [
      "deployments",
    ]
    verbs = [
      "get",
      "create",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "traefik.io",
    ]
    resources = [
      "ingressroutes",
      "middlewares",
    ]
    verbs = [
      "get",
      "create",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "monitoring.coreos.com",
    ]
    resources = [
      "podmonitors",
      "servicemonitors",
    ]
    verbs = [
      "get",
      "create",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "batch",
    ]
    resources = [
      "cronjobs",
    ]
    verbs = [
      "get",
      "create",
      "patch",
    ]
  }
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = var.k8s_namespace
    namespace = var.k8s_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.service_account.metadata.0.name
    }
  }

  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_role_binding" "role_binding" {
  metadata {
    name      = var.k8s_namespace
    namespace = var.k8s_namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata.0.name
    namespace = var.k8s_namespace

  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.role.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}
