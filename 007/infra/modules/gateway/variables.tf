variable "gateway_image_name" {
  type = string
}

variable "gateway_container_name" {
  type = string
}
variable "gateway_external_port" {
  type = number
}
variable "network_id" {
  type = string
}
variable "gateway_init_script_path" {
  description = "Ruta al archivo nginx.conf de configuración del proxy."
  type        = string
}
