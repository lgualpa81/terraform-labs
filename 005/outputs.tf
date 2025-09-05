# Output que muestra información del workspace
output "environment_info" {
  value = {
    workspace = terraform.workspace
    filename  = local_file.app_config.filename
    is_dev    = terraform.workspace == "dev"
    is_prod   = terraform.workspace == "prod"
  }
}

output "app_info" {
  description = "Información de la aplicación desplegada"
  value = {
    environment          = terraform.workspace
    app_url              = "http://localhost:${local.current_config.external_port}"
    replica_count        = local.current_config.replica_count
    memory_per_container = "${local.current_config.memory_mb}MB"
    container_names      = docker_container.app[*].name
    network_name         = docker_network.app_network.name
  }
}

output "quick_commands" {
  description = "Comandos útiles para este ambiente"
  value = {
    view_logs         = "docker logs ${local.container_name}-1"
    connect_container = "docker exec -it ${local.container_name}-1 /bin/bash"
    test_app          = "curl http://localhost:${local.current_config.external_port}"
    list_containers   = "docker ps --filter label=environment=${terraform.workspace}"
  }
}
