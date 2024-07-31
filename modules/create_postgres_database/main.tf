resource "random_string" "db_username" {
  length  = 12
  upper   = false
  numeric = false
}

resource "random_password" "db_password" {
  length = 20
}

resource "random_string" "exporter_username" {
  length  = 12
  upper   = false
  numeric = false
}

resource "random_password" "exporter_password" {
  length = 20
}

# resource "helm_release" "database" {
#   name       = var.k8s_name
#   repository = "https://mucsi96.github.io/k8s-helm-charts"
#   chart      = "postgres-db"
#   version    = "1.0.0"
#   namespace  = var.k8s_namespace
#   wait       = true
#   # https://github.com/mucsi96/k8s-helm-charts/tree/main/charts/postgres_db
#   values = [yamlencode({
#     name             = var.db_name
#     username         = random_string.db_username.result
#     password         = random_password.db_password.result
#     exporterUsername = random_string.exporter_username.result
#     exporterPassword = random_password.exporter_password.result
#   })]
# }
