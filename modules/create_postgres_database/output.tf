output "username" {
  value     = random_string.db_username.result
  sensitive = true
}

output "password" {
  value     = random_password.db_password.result
  sensitive = true
}
