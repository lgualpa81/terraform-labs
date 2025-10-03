resource "docker_volume" "redis_data" {
  name = "redis_data"
}

resource "docker_image" "redis" {
  name         = var.redis_image_name
  keep_locally = true
}

resource "docker_container" "redis" {
  name  = var.redis_container_name
  image = docker_image.redis.image_id

  restart = "unless-stopped"

  command = [
    "redis-server",
    "--appendonly", "yes",
    "--appendfsync", "everysec"
  ]

  ports {
    internal = 6379
    external = var.redis_external_port
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name    = var.network_id
    aliases = ["cache", "redis"]
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "10s"
    timeout  = "3s"
    retries  = 3
  }
}

