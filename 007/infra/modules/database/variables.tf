variable "pg_container_name" { type = string }
variable "pg_image_name" { type = string }
variable "network_id" { type = string }
variable "pg_volume_name" { type = string }
variable "pg_db_user" { type = string }
variable "pg_db_password" { type = string }
variable "pg_db_name" { type = string }
variable "pg_external_port" {
  description = "Puerto externo para PostgreSQL"
  type        = number
}
variable "pg_init_script_path" {
  description = "Ruta al archivo .sql de inicialización para la base de datos."
  type        = string
}
