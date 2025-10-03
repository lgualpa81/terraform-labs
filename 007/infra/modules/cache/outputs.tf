
output "container_name" {
  description = "El nombre del contenedor de cache/redis."
  value       = docker_container.redis.name
}
