variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "mi-app"
}

# Configuración por workspace usando locals
locals {
  # Configuración específica por ambiente
  env_config = {
    dev = {
      replica_count = 1
      memory_mb     = 256
      external_port = 8080
      image_tag     = "1.28.0-alpine"
    }
    staging = {
      replica_count = 2
      memory_mb     = 512
      external_port = 8081
      image_tag     = "1.28.0-alpine"
    }
    prod = {
      replica_count = 3
      memory_mb     = 1024
      external_port = 80
      image_tag     = "latest"
    }
  }

  # Configuración actual basada en el workspace
  current_config = local.env_config[terraform.workspace]

  # Nombre único por ambiente
  container_name = "${var.app_name}-${terraform.workspace}"
}
