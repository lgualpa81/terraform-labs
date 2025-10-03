
resource "docker_image" "vote" {
  name         = var.vote_image_name
  keep_locally = true
}

resource "docker_container" "vote" {
  name  = var.vote_container_name
  image = docker_image.vote.image_id

  restart = "unless-stopped"

  env = [
    "REDIS_HOST=${var.redis_host}",
    "DATABASE_HOST=${var.pg_host}",
    "DATABASE_NAME=${var.pg_db_name}",
    "DATABASE_USER=${var.pg_db_user}",
    "DATABASE_PASSWORD=${var.pg_db_password}"
  ]


  networks_advanced {
    name    = var.network_id
    aliases = ["vote"]
  }

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:80/healthz"]
    interval     = "10s"
    timeout      = "3s"
    retries      = 3
    start_period = "40s"
  }
}
