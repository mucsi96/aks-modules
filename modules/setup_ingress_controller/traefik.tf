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
  #https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml
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
        email = var.letsencrypt_email
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory" # Staging server
        caServer = "https://acme-v02.api.letsencrypt.org/directory" # Production server
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
    ingressRoute = {
      dashboard = {
        enabled     = true
        matchRule   = "Host(`traefik.${var.azure_resource_group_name}.${var.dns_zone}`)"
        entryPoints = ["websecure"]
        tls = {
          enabled = true
        }
        middlewares = [
          {
            name = "traefik-dashboard-auth"
          }
        ]
      }
    }
    extraObjects = [
      {
        apiVersion = "traefik.io/v1alpha1"
        kind       = "Middleware"
        metadata = {
          name = "traefik-dashboard-auth"
        }
        spec = {
          forwardauth = {
            address = "http://agent:8080/authorize?namespace=traefik&scopes=${azuread_application.traefik.client_id}/dashboard-access&requiredRoles=Dashboard.Viewer"
            addAuthCookiesToResponse = [
              "accessToken",
              "refreshToken",
              "idToken"
            ]
          }
        }
      }
    ]
  })]
}
