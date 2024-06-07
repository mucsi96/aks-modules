output "app_id" {
  value = azuread_application.traefik.id
}

output "dashboard_access_scope_id" {
  value = random_uuid.traefik_dashboard_access_scope_id.result
}

output "dashboard_access_scope" {
  value = "${local.app_uri}/dashboard-access"
}

