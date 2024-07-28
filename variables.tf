locals {
  azure_resource_group_name = "p02"
  azure_location            = "centralindia"
  azure_k8s_version         = "1.29.4"
  traefik_chart_version     = "30.0.0" #https://github.com/traefik/traefik-helm-chart/releases
  token_agent_version       = 1
}
