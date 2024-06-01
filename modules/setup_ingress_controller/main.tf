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

    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }

}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = var.azure_resource_group_name
  resource_group_name = var.azure_resource_group_name
}

data "azurerm_public_ip" "public_ip" {
  resource_group_name = data.azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
  name                = var.azure_resource_group_name
}

resource "azurerm_dns_zone" "dns_zone" {
  resource_group_name = var.azure_resource_group_name
  name                = var.dns_zone
}

resource "azurerm_dns_a_record" "dns_a_record" {
  resource_group_name = var.azure_resource_group_name
  zone_name           = azurerm_dns_zone.dns_zone.name
  name                = "*"
  ttl                 = 300
  records             = [data.azurerm_public_ip.public_ip.ip_address]
}

resource "azurerm_user_assigned_identity" "dns_challenge_identity" {
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  name                = "dns_challenge_identity"
}

# https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#create-the-federated-identity-credential
resource "azurerm_federated_identity_credential" "dns_challenge_identity_credential" {
  resource_group_name = var.azure_resource_group_name
  name                = "dns_challenge_identity_credential"
  parent_id           = azurerm_user_assigned_identity.dns_challenge_identity.id
  issuer              = data.azurerm_kubernetes_cluster.kubernetes_cluster.oidc_issuer_url
  subject             = "system:serviceaccount:${kubernetes_service_account.service_account.metadata[0].namespace}:${kubernetes_service_account.service_account.metadata[0].name}"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "dns_challenge_contributor" {
  scope                = azurerm_dns_zone.dns_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.dns_challenge_identity.principal_id
}

resource "kubernetes_namespace" "k8s_namespace" {
  metadata {
    name = "traefik"
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.dns_challenge_identity.client_id
      "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
    }
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.traefik_chart_version
  namespace  = kubernetes_namespace.k8s_namespace.metadata[0].name
  wait       = true
  values = [yamlencode({
    podSecurityContext = {
      fsGroup = 65532
    }
    persistence = {
      enabled = true
      size    = "128Mi"
    }
    certResolvers = {
      letsencrypt = {
        email    = var.letsencrypt_email
        caServer = "https://acme-staging-v02.api.letsencrypt.org/directory" # Staging server
        # caServer = "https://acme-v02.api.letsencrypt.org/directory" # Production server
        dnsChallenge = {
          provider         = "azuredns"
          delayBeforeCheck = 10
        }
        storage = "/data/acme.json"
      }
    }
    env = [
      {
        name  = "AZURE_SUBSCRIPTION_ID"
        value = data.azurerm_client_config.current.subscription_id
      },
      {
        name  = "AZURE_RESOURCE_GROUP"
        value = var.azure_resource_group_name
      },
      {
        name  = "AZURE_AUTH_METHOD"
        value = "wli"
      }
    ]
    serviceAccount = {
      name = kubernetes_service_account.service_account.metadata.0.name
    }
    deployment = {
      podLabels = {
        "azure.workload.identity/use" = "true"
      }
      initContainers = [
        {
          name    = "volume-permissions"
          image   = "busybox:latest"
          command = ["sh", "-c", "touch /data/acme.json; chmod -v 600 /data/acme.json"]
          volumeMounts = [
            {
              name      = "data"
              mountPath = "/data"
            }
          ]
        }
      ]
    }
    logs = {
      general = {
        level = "DEBUG"
      }
      access = {
        enabled = true
      }
    }
    ports = {
      web = {
        redirectTo = {
          port   = "websecure"
          scheme = "https"
        }
      }
    }
    service = {
      spec = {
        type = "LoadBalancer"
      }
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-resource-group" = data.azurerm_kubernetes_cluster.kubernetes_cluster.node_resource_group
        "service.beta.kubernetes.io/azure-pip-name"                     = var.azure_resource_group_name
        "service.beta.kubernetes.io/azure-allowed-ip-ranges"            = var.ip_range
      }
    }
  })]
}
