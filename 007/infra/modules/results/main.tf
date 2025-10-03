
resource "docker_image" "result" {
  name         = var.result_image_name
  keep_locally = true
}

resource "docker_container" "result" {
  name  = var.result_container_name
  image = docker_image.result.image_id

  restart = "unless-stopped"
  ports {
    internal = 3000
    external = var.result_external_port
  }

  env = [
    "APP_PORT=3000",
    "DATABASE_HOST=${var.pg_host}",
    "DATABASE_NAME=${var.pg_db_name}",
    "DATABASE_USER=${var.pg_db_user}",
    "DATABASE_PASSWORD=${var.pg_db_password}"
  ]


  networks_advanced {
    name    = var.network_id
    aliases = ["result"]
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:3000/healthz"]
    interval     = "10s"
    timeout      = "3s"
    retries      = 3
    start_period = "40s"
  }
}
