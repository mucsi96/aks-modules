resource "kubernetes_namespace" "k8s_namespace" {
  metadata {
    name = "traefik"
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
        "service.beta.kubernetes.io/azure-pip-name"                     = var.resource_group_name
        "service.beta.kubernetes.io/azure-allowed-ip-ranges"            = var.ip_range
      }
    }
    tlsStore = {
      default = {
        defaultCertificate = {
          secretName = "traefik-default-cert"
        }
      }
    }
    ingressRoute = {
      dashboard = {
        enabled     = true
        matchRule   = "Host(`traefik.${var.resource_group_name}.${var.dns_zone}`)"
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
        apiVersion = "v1"
        kind       = "Secret"
        metadata = {
          name = "traefik-default-cert"
        }
        stringData = {
          "tls.crt" = acme_certificate.certificate.certificate_pem
          "tls.key" = acme_certificate.certificate.private_key_pem
        }
      },
      {
        apiVersion = "traefik.io/v1alpha1"
        kind       = "Middleware"
        metadata = {
          name = "traefik-dashboard-auth"
        }
        spec = {
          forwardAuth = {
            address = "http://token-agent.identity-provider.svc:8080/authorize?namespace=traefik&scopes=${azuread_application.traefik.client_id}/dashboard-access&requiredRoles=Dashboard.Viewer"
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
