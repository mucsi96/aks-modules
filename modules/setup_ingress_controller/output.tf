output "hostname" {
  value = "${var.resource_group_name}.${var.dns_zone}"
}

output "tls_certificate" {
  value = acme_certificate.certificate.certificate_p12
}
