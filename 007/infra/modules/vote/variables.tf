variable "network_id" { type = string }
variable "vote_image_name" {
  type = string
}
variable "vote_container_name" {
  type = string
}
variable "redis_host" {
  type = string
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
