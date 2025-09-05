# El contenido cambia según el workspace
resource "local_file" "app_config" {
  filename = "outputs/app-${terraform.workspace}.conf"
  content  = <<-EOF
    [Application]
    environment = ${terraform.workspace}
    debug = ${terraform.workspace == "dev" ? "true" : "false"}
    port = ${terraform.workspace == "dev" ? "8080" : "80"}
    
    [Database]
    host = ${terraform.workspace}-db.example.com
    name = app_${terraform.workspace}
  EOF
}



# Imagen de nginx
resource "docker_image" "nginx" {
  name         = "nginx:${local.current_config.image_tag}"
  keep_locally = false
}

# Red específica por ambiente
resource "docker_network" "app_network" {
  name = "${local.container_name}-network"
}

# Contenedores según configuración del ambiente
resource "docker_container" "app" {
  count = local.current_config.replica_count

  name  = "${local.container_name}-${count.index + 1}"
  image = docker_image.nginx.image_id

  # Puerto solo en el primer contenedor
  dynamic "ports" {
    for_each = count.index == 0 ? [1] : []
    content {
      internal = 80
      external = local.current_config.external_port
    }
  }

  # Variables de entorno
  env = [
    "ENVIRONMENT=${terraform.workspace}",
    "REPLICA_ID=${count.index + 1}",
    "TOTAL_REPLICAS=${local.current_config.replica_count}"
  ]

  # Límites de recursos
  memory = local.current_config.memory_mb

  # Conectar a la red
  networks_advanced {
    name = docker_network.app_network.name
  }

  # Labels para identificar
  labels {
    label = "environment"
    value = terraform.workspace
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}
