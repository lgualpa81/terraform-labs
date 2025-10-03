variable "network_id" { type = string }
variable "result_image_name" {
  type = string
}
variable "result_container_name" {
  type = string
}
variable "result_external_port" {
  type = number
}

variable "pg_host" {
  type = string
}
variable "pg_db_name" {
  type = string
}
variable "pg_db_user" {
  type = string
}
variable "pg_db_password" {
  type      = string
  sensitive = true
}
