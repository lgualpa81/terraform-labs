## 🔌 ¿Qué es el Provider Docker?

El Docker Provider permite a Terraform gestionar recursos Docker:

- 🖼️ Imágenes Docker (pull, build, tag)
- 📦 Contenedores (crear, configurar, gestionar lifecycle)
- 🌐 Redes (crear redes personalizadas)
- 💾 Volúmenes (almacenamiento persistente)
- 🏷️ Registries (autenticación y gestión)

---

## 🛠️ Configuración Inicial

### Prerequisitos

```bash
# Verificar que Docker esté instalado y funcionando
docker version
docker ps

# Verificar Terraform
terraform version
```

### Configuración del provider

`versions.tf`

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Configuración del provider Docker
provider "docker" {
}
```

<blockquote>

⚠️ Nota:
El provider oficial de Docker para Terraform (kreuzwerker/docker) está en mantenimiento limitado.
Existe un nuevo provider alternativo, calxus/docker, que es compatible y ofrece mejoras.

Para usarlo, cambia en required_providers:

```hcl
terraform {
  required_providers {
    docker = {
      source  = "calxus/docker"
      version = "~> 3.0"
    }
  }
}
```

La sintaxis de recursos y configuración es muy similar, pero revisa la documentación oficial para detalles y nuevas funcionalidades.

</blockquote>

---

## 🖼️ Gestión de Imágenes Docker

### Pulling Imágenes

```hcl
# Imagen base desde Docker Hub
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false  # Eliminar imagen al hacer destroy
}

# Imagen específica con tag
resource "docker_image" "postgres" {
  name         = "postgres:15-alpine"
  keep_locally = true   # Mantener imagen localmente
}

# Imagen con digest específico (inmutable)
resource "docker_image" "redis" {
  name = "redis@sha256:..."
}
```

### Building Imágenes Personalizadas

```hcl
# Build desde Dockerfile
resource "docker_image" "custom_app" {
  name = "web-app:latest"

  build {
    context    = path.module  # Directorio con Dockerfile
    dockerfile = "Dockerfile"

    # Args de build
    build_args = {
      APP_VERSION = "1.0.0"
      ENV         = "production"
    }

    # Tags adicionales
    tag = [
      "web-app:1.0.0",
      "web-app:latest"
    ]
  }

  # Triggers para rebuild
  triggers = {
    dockerfile_hash = filemd5("${path.module}/Dockerfile")
    src_hash       = sha256(join("", [
      for f in fileset(path.module, "src/**") : filemd5("${path.module}/${f}")
    ]))
  }
}
```

---

## 📦 Gestión de Contenedores

### Contenedor Básico

```hcl
resource "docker_container" "nginx_server" {
  name  = "my-nginx"
  image = docker_image.nginx.image_id

  # Configuración básica
  restart = "unless-stopped"

  # Puertos
  ports {
    internal = 80
    external = 8080
    protocol = "tcp"
  }

  # Variables de entorno
  env = [
    "ENV=production",
    "DEBUG=false"
  ]

  # Labels
  labels {
    label = "project"
    value = "devops-challenge"
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }
}
```

### Contenedor Avanzado

```hcl
resource "docker_container" "webapp" {
  name  = "coder-webapp"
  image = docker_image.custom_app.image_id

  # Configuración de restart
  restart = "always"

  # Múltiples puertos
  ports {
    internal = 3000
    external = 3000
  }

  ports {
    internal = 3001
    external = 3001
  }

  # Variables de entorno desde archivo
  env = [
    "NODE_ENV=production",
    "PORT=3000",
    "DATABASE_URL=${var.database_url}",
    "REDIS_URL=${var.redis_url}"
  ]

  # Health check
  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:3000/health"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "40s"
  }

  # Límites de recursos
  memory    = 512   # MB
  memory_swap = 1024  # MB
  cpu_shares = 512

  # Configuración de logs
  log_driver = "json-file"
  log_opts = {
    "max-size" = "10m"
    "max-file" = "3"
  }

  # Comando personalizado
  command = ["npm", "start"]

  # Working directory
  working_dir = "/app"

  # Usuario
  user = "1000:1000"

  # Capabilities
  capabilities {
    add  = ["NET_ADMIN"]
    drop = ["ALL"]
  }
}
```

---

## 🌐 Gestión de Redes

### Red Personalizada

```hcl
resource "docker_network" "app_network" {
  name   = "coder-app-network"
  driver = "bridge"

  # Configuración IPAM
  ipam_config {
    subnet   = "172.20.0.0/16"
    gateway  = "172.20.0.1"
    ip_range = "172.20.240.0/20"
  }

  # Opciones adicionales
  options = {
    "com.docker.network.bridge.name" = "coder-bridge"
  }

  # Labels
  labels {
    label = "project"
    value = "devops-challenge"
  }
}

# Conectar contenedores a la red
resource "docker_container" "app_with_network" {
  name  = "app-networked"
  image = docker_image.custom_app.image_id

  # Conectar a red personalizada
  networks_advanced {
    name = docker_network.app_network.name
    ipv4_address = "172.20.0.10"
    aliases = ["app", "webapp"]
  }

  # También puede estar en la red por defecto
  networks_advanced {
    name = "bridge"
  }
}
```

---

## 💾 Gestión de Volúmenes

### Volúmenes Nombrados

```hcl
# Crear volumen
resource "docker_volume" "app_data" {
  name = "coder-app-data"

  # Driver específico
  driver = "local"

  # Opciones del driver
  driver_opts = {
    type   = "none"
    o      = "bind"
    device = "/host/path/data"
  }

  # Labels
  labels {
    label = "backup"
    value = "daily"
  }
}

# Usar volumen en contenedor
resource "docker_container" "app_with_volume" {
  name  = "app-persistent"
  image = docker_image.custom_app.image_id

  # Montar volumen nombrado
  volumes {
    volume_name    = docker_volume.app_data.name
    container_path = "/app/data"
    read_only      = false
  }

  # Bind mount
  volumes {
    host_path      = "/host/config"
    container_path = "/app/config"
    read_only      = true
  }

  # Volumen temporal
  volumes {
    container_path = "/tmp"
    from_container = "temp-container"
  }
}
```

---

## 🔍 Comandos Útiles

### Gestión del Stack

```hcl
# Inicializar
terraform init

# Planificar
terraform plan

# Aplicar
terraform apply -auto-approve

# Ver estado
terraform show

# Ver outputs
terraform output

# Verificar contenedores
docker ps

# Ver logs
docker logs tf-postgres
docker logs tf-redis
docker logs tf-nginx

# Limpiar todo
terraform destroy -auto-approve
```

### Debugging

```hcl
# Inspeccionar red
docker network inspect tf-voting-network

# Inspeccionar volúmenes
docker volume inspect postgres_data

# Conectar a contenedor
docker exec -it tf-postgres psql -U postgres -d voting_app

# Verificar conectividad
docker exec tf-nginx ping tf-postgres
docker exec tf-nginx ping tf-redis
```

## 📊 Data Sources

Los data sources permiten obtener información de recursos existentes:

```hcl
# Obtener información de imagen existente
data "docker_image" "existing_nginx" {
  name = "nginx:latest"
}

# Obtener información de red existente
data "docker_network" "existing_network" {
  name = "bridge"
}

# Usar en recursos
resource "docker_container" "app_existing_network" {
  name  = "app-on-bridge"
  image = data.docker_image.existing_nginx.image_id

  networks_advanced {
    name = data.docker_network.existing_network.name
  }
}
```

---

## 🚨 Mejores Prácticas

### 1. Gestión de Imágenes

```hcl
# ✅ Usar tags específicos en producción
resource "docker_image" "app_prod" {
  name = "myapp:v1.2.3"  # No usar 'latest'
}

# ✅ Usar keep_locally apropiadamente
resource "docker_image" "base_image" {
  name         = "postgres:15-alpine"
  keep_locally = true  # Para imágenes base
}
```

### 2. Configuración de Contenedores

```hcl
# ✅ Usar health checks
resource "docker_container" "app" {
  # ... configuración ...

  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost/health"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}

# ✅ Configurar límites de recursos
resource "docker_container" "app" {
  # ... configuración ...

  memory      = 512
  memory_swap = 1024
  cpu_shares  = 512
}
```

### 3. Redes y Seguridad

```hcl
# ✅ Usar redes personalizadas
resource "docker_network" "app_network" {
  name   = "app-network"
  driver = "bridge"

  # Configuración específica
  ipam_config {
    subnet = "172.20.0.0/16"
  }
}

# ✅ Exponer solo puertos necesarios
resource "docker_container" "database" {
  # ... configuración ...

  # NO exponer puerto si no es necesario
  # ports {
  #   internal = 5432
  #   external = 5432
  # }
}
```

### 4. Variables Sensibles

```hcl
# ✅ Marcar passwords como sensitive
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

---
