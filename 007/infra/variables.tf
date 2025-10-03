
variable "project_name" {
  description = "Nombre base para los recursos del proyecto."
  type        = string
}

variable "network_name" {
  description = "Nombre de la red Docker personalizada."
  type        = string
  default     = "voting-network"
}


# --- Variables de Imágenes Docker ---
variable "images" {
  description = "Mapa con los nombres de las imágenes Docker a utilizar."
  type        = map(string)
  default = {
    vote   = "voting-app-vote:latest"
    worker = "voting-app-worker:latest"
    result = "voting-app-result:latest"
    db     = "postgres:16-alpine",
    cache  = "redis:7-alpine",
    nginx  = "nginx:alpine"
  }
}

# --- Variables de Configuración de Contenedores ---

variable "external_ports" {
  description = "Puertos a exponer en la máquina anfitriona (host)."
  type = object({
    nginx  = number
    result = number
    pg     = number
    redis  = number
  })
}

# --- Variables para la autenticación en Docker Hub ---
# variable "docker_username" {
#   description = "Usuario de Docker Hub."
#   type        = string
#   nullable    = false
# }

# variable "docker_token" {
#   description = "Token de acceso personal (PAT) de Docker Hub."
#   type        = string
#   sensitive   = true
#   nullable    = false
# }

variable "pg_host" {
  description = "Host para la base de datos PostgreSQL."
  type        = string
  default     = "database"
}

variable "pg_db_name" {
  description = "Nombre para la base de datos PostgreSQL."
  type        = string
  default     = "votes"
}

variable "pg_db_user" {
  description = "Usuario para la base de datos PostgreSQL."
  type        = string
  default     = "postgres"
}

variable "pg_db_password" {
  description = "Contraseña para el usuario de la base de datos."
  type        = string
  sensitive   = true
}

variable "redis_host" {
  type    = string
  default = "redis"
}
