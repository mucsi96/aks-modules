resource "kubernetes_namespace" "k8s_namespace" {
  metadata {
    name = "identity-provider"
  }
}

resource "helm_release" "token_agent" {
  name       = "token-agent"
  repository = "https://mucsi96.github.io/k8s-helm-charts"
  chart      = "node-app"
  version    = "8.0.0"
  namespace  = kubernetes_namespace.k8s_namespace.metadata[0].name
  wait       = true
  #https://github.com/mucsi96/k8s-helm-charts/tree/main/charts/node_app
  values = [yamlencode({
    image = "mucsi96/auth-agent:${var.token_agent_version}"
    host = "auth.${var.hostname}"
    basePath = ""
    env = {
      ISSUER        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
      PUBLIC_URL    = "https://auth.${var.hostname}"
      COOKIE_DOMAIN = var.hostname
      CLIENT_ID     = azuread_application.token_agent.client_id
      CLIENT_SECRET = azuread_application_password.password.value
    }
  })]
}
