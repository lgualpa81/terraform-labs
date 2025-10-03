resource "docker_image" "gateway" {
  name         = var.gateway_image_name
  keep_locally = true
}

resource "docker_container" "gateway" {
  name  = var.gateway_container_name
  image = docker_image.gateway.image_id
  ports {
    internal = 80
    external = var.gateway_external_port
  }
  networks_advanced {
    name = var.network_id
  }

  volumes {
    # 2. Bind mount para el script de inicialización
    host_path      = var.gateway_init_script_path
    container_path = "/etc/nginx/conf.d/vote.conf"
    read_only      = true
  }

  command = [
    "/bin/sh",
    "-c",
    "rm -f /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
  ]

  # Healthcheck para verificar que nginx responde
  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost/health"]
    interval = "10s"
    timeout  = "3s"
    retries  = 3
  }
}
