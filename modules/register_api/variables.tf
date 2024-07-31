variable "owner" {
  description = "The owner of the resources"
  type        = string
}

variable "display_name" {
  description = "The display name of the API"
  type        = string
}

variable "roles" {
  description = "The roles to create for the API"
  type        = list(string)
}

variable "scopes" {
  description = "The scopes to create for the API"
  type        = list(string)
}
