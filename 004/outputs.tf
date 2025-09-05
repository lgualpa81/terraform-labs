output "application_urls" {
  description = "URLs de acceso a la aplicación"
  sensitive   = true
  value = {
    nginx    = "http://localhost:${var.nginx_external_port}"
    postgres = "postgresql://${var.database_user}:${var.database_password}@localhost:${var.postgres_external_port}/${var.database_name}"
    redis    = "redis://localhost:${var.redis_external_port}"
  }
}

output "container_info" {
  description = "Información de contenedores"
  value = {
    postgres = {
      id   = docker_container.postgres.id
      name = docker_container.postgres.name
      ip   = docker_container.postgres.network_data[0].ip_address
    }
    redis = {
      id   = docker_container.redis.id
      name = docker_container.redis.name
      ip   = docker_container.redis.network_data[0].ip_address
    }
    nginx = {
      id   = docker_container.nginx.id
      name = docker_container.nginx.name
      ip   = docker_container.nginx.network_data[0].ip_address
    }
  }
}

output "network_info" {
  description = "Información de la red"
  value = {
    name   = docker_network.app_network.name
    driver = docker_network.app_network.driver
    subnet = tolist(docker_network.app_network.ipam_config)[0].subnet
  }
}

output "volumes_info" {
  description = "Información de volúmenes"
  value = {
    postgres_volume = docker_volume.postgres_data.name
    redis_volume    = docker_volume.redis_data.name
  }
}
