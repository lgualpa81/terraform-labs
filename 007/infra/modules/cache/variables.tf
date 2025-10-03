variable "redis_container_name" { type = string }
variable "redis_image_name" { type = string }
variable "redis_volume_name" { type = string }
variable "redis_external_port" {
  type = number
}
variable "network_id" { type = string }
