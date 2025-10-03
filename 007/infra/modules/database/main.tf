resource "docker_image" "postgres" {
  name = var.pg_image_name
}

resource "docker_volume" "postgres_data" {
  name = var.pg_volume_name
}

resource "docker_container" "postgres" {
  name  = var.pg_container_name
  image = docker_image.postgres.image_id

  restart = "unless-stopped"

  env = [
    "POSTGRES_DB=${var.pg_db_name}",
    "POSTGRES_USER=${var.pg_db_user}",
    "POSTGRES_PASSWORD=${var.pg_db_password}"
  ]

  ports {
    internal = 5432
    external = var.pg_external_port
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name    = var.network_id
    aliases = ["database", "postgres"]
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.pg_db_user}"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}
