resource "azurerm_dns_zone" "dns_zone" {
  resource_group_name = var.resource_group_name
  name                = var.dns_zone
}

resource "azurerm_dns_a_record" "dns_a_record" {
  resource_group_name = var.resource_group_name
  zone_name           = azurerm_dns_zone.dns_zone.name
  name                = var.resource_group_name
  ttl                 = 3600
  records             = [data.azurerm_public_ip.public_ip.ip_address]
}

resource "azurerm_dns_cname_record" "name" {
  resource_group_name = var.resource_group_name
  zone_name           = azurerm_dns_zone.dns_zone.name
  name                = "*.${var.resource_group_name}"
  ttl                 = 3600
  record              = "${var.resource_group_name}.${var.dns_zone}"
}

resource "azurerm_user_assigned_identity" "dns_challenge_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "dns_challenge_identity"
}

# https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#create-the-federated-identity-credential
resource "azurerm_federated_identity_credential" "dns_challenge_identity_credential" {
  resource_group_name = var.resource_group_name
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