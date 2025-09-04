## Variables: Fundamentos

### 🏗️ Anatomía de una Variable

```hcl
variable "nombre_variable" {
  description = "Descripción clara y útil"       # 📝 Documentación
  type        = string                           # 🏷️ Tipo de dato
  default     = "valor_por_defecto"              # 🔧 Valor opcional
  sensitive   = false                            # 🔒 ¿Es sensitiva?
  nullable    = false                            # ❌ ¿Permite null?

  validation {                                   # ✅ Reglas de validación
    condition     = length(var.nombre_variable) > 3
    error_message = "Debe tener más de 3 caracteres."
  }
}
```

### 🎯 Variables con Validaciones

# Variable con múltiples validaciones

```hcl
variable "app_name" {
  description = "Nombre de la aplicación (debe seguir convenciones)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "app_name debe empezar con letra, solo contener minúsculas, números y guiones."
  }

  validation {
    condition     = length(var.app_name) >= 3 && length(var.app_name) <= 32
    error_message = "app_name debe tener entre 3 y 32 caracteres."
  }
}

# Variable de entorno con validación estricta
variable "environment" {
  description = "Entorno de despliegue (dev/staging/prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser exactamente: dev, staging, o prod."
  }
}

# Variable numérica con rangos
variable "instance_count" {
  description = "Número de instancias (1-10)"
  type        = number

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count debe estar entre 1 y 10."
  }
}

# Variable con validación de formato de email
variable "admin_email" {
  description = "Email del administrador"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "admin_email debe ser un email válido."
  }
}

# Variable con validación de CIDR
variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr debe ser un bloque CIDR válido."
  }

  validation {
    condition     = split("/", var.vpc_cidr)[1] >= 16 && split("/", var.vpc_cidr)[1] <= 24
    error_message = "vpc_cidr debe tener subnet mask entre /16 y /24."
  }
}

# Variable booleana con valor inteligente
variable "enable_monitoring" {
  description = "Habilitar monitoreo (recomendado para prod)"
  type        = bool
  default     = true
}

# Variable sensitive para secrets
variable "database_password" {
  description = "Password de la base de datos"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.database_password) >= 8
    error_message = "Password debe tener al menos 8 caracteres."
  }
}
```

## 🏷️ Tipos de Datos Avanzados

### 🔤 Tipos Primitivos

```hcl
# String con validación avanzada
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-west-2"

  validation {
    condition = can(regex("^(us|eu|ap|sa|ca|me|af)-(north|south|east|west|central)-[1-9]$", var.region))
    error_message = "Debe ser una región válida de AWS."
  }
}

# Number con límites específicos
variable "port" {
  description = "Puerto de la aplicación"
  type        = number
  default     = 8080

  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Puerto debe estar entre 1024 y 65535."
  }
}

# Boolean con lógica condicional
variable "enable_ssl" {
  description = "Habilitar SSL (obligatorio en prod)"
  type        = bool
  default     = true
}
```

### 📚 Tipos Complejos - Lista (List)

```hcl
# Lista simple
variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Debe especificar al menos 2 zonas de disponibilidad."
  }
}

# Lista de números
variable "allowed_ports" {
  description = "Puertos permitidos en el firewall"
  type        = list(number)
  default     = [22, 80, 443, 8080]
}

# Lista con validación de contenido
variable "supported_instance_types" {
  description = "Tipos de instancia soportados"
  type        = list(string)
  default     = ["t3.micro", "t3.small", "t3.medium"]

  validation {
    condition = alltrue([
      for instance_type in var.supported_instance_types :
      can(regex("^(t3|t2|m5|c5)\\.(micro|small|medium|large|xlarge)$", instance_type))
    ])
    error_message = "Todos los tipos de instancia deben ser válidos de AWS."
  }
}
```

### 🗂️ Tipos Complejos - Mapa (Map)

```hcl
# Map simple
variable "tags" {
  description = "Tags comunes para recursos"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "devops-challenge"
    Owner       = "coder"
    Team        = "devops"
  }
}

# Map con validación
variable "environment_configs" {
  description = "Configuraciones específicas por entorno"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
  }))

  default = {
    dev = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 2
    }
    staging = {
      instance_type = "t3.small"
      min_size      = 2
      max_size      = 4
    }
    prod = {
      instance_type = "t3.medium"
      min_size      = 3
      max_size      = 10
    }
  }

  validation {
    condition = alltrue([
      for env, config in var.environment_configs :
      config.min_size <= config.max_size
    ])
    error_message = "min_size debe ser menor o igual que max_size para todos los entornos."
  }
}

# Map anidado complejo
variable "network_config" {
  description = "Configuración de red por región"
  type = map(object({
    vpc_cidr = string
    subnets = map(object({
      cidr = string
      type = string
    }))
  }))

  default = {
    "us-west-2" = {
      vpc_cidr = "10.0.0.0/16"
      subnets = {
        public_1 = {
          cidr = "10.0.1.0/24"
          type = "public"
        }
        private_1 = {
          cidr = "10.0.2.0/24"
          type = "private"
        }
      }
    }
  }
}
```

### 🏗️ Tipos Complejos - Objeto (Object)

```hcl
# Object simple
variable "database_config" {
  description = "Configuración de base de datos"
  type = object({
    name     = string
    port     = number
    username = string
    ssl      = bool
  })

  default = {
    name     = "app_db"
    port     = 5432
    username = "admin"
    ssl      = true
  }
}

# Object complejo con validaciones
variable "application_config" {
  description = "Configuración completa de la aplicación"
  type = object({
    name    = string
    version = string

    # Configuración de runtime
    runtime = object({
      language = string
      version  = string
      memory   = number
      cpu      = number
    })

    # Configuración de base de datos
    database = object({
      engine   = string
      version  = string
      storage  = number
      backups  = bool
    })

    # Features opcionales
    features = object({
      monitoring    = bool
      logging       = bool
      caching       = bool
      load_balancer = bool
    })

    # Configuración de red
    networking = object({
      vpc_cidr     = string
      subnet_count = number
      enable_nat   = bool
    })
  })

  # Validaciones del objeto
  validation {
    condition     = contains(["python", "nodejs", "java", "go"], var.application_config.runtime.language)
    error_message = "Runtime language debe ser uno de: python, nodejs, java, go."
  }

  validation {
    condition     = var.application_config.runtime.memory >= 512 && var.application_config.runtime.memory <= 8192
    error_message = "Memory debe estar entre 512MB y 8GB."
  }

  validation {
    condition     = contains(["postgres", "mysql", "mongodb"], var.application_config.database.engine)
    error_message = "Database engine debe ser: postgres, mysql, o mongodb."
  }
}

# Object con valores opcionales
variable "monitoring_config" {
  description = "Configuración de monitoreo (opcional)"
  type = object({
    enabled          = bool
    retention_days   = optional(number, 30)
    alert_email      = optional(string, "admin@company.com")
    slack_webhook    = optional(string)
    custom_metrics   = optional(list(string), [])
  })

  default = {
    enabled = true
  }
}
```

### 📦 Tipos Complejos - Set

```hcl
# Set de strings (sin duplicados)
variable "security_groups" {
  description = "IDs de grupos de seguridad únicos"
  type        = set(string)
  default     = ["sg-123", "sg-456", "sg-789"]

  validation {
    condition = alltrue([
      for sg in var.security_groups :
      can(regex("^sg-[a-z0-9]{8,17}$", sg))
    ])
    error_message = "Todos los security groups deben tener formato válido."
  }
}

# Set de objetos
variable "allowed_cidrs" {
  description = "CIDRs permitidos para acceso"
  type = set(object({
    cidr        = string
    description = string
  }))

  default = [
    {
      cidr        = "10.0.0.0/8"
      description = "Red interna"
    },
    {
      cidr        = "172.16.0.0/12"
      description = "Red privada"
    }
  ]
}
```

### 🔄 Tipos Dinámicos y Tuplas

```hcl
# Tipo any para flexibilidad
variable "custom_config" {
  description = "Configuración personalizada flexible"
  type        = any
  default     = {}
}

# Tupla con tipos específicos
variable "server_specs" {
  description = "Especificaciones del servidor [tipo, vcpu, memoria, storage]"
  type        = tuple([string, number, number, number])
  default     = ["t3.medium", 2, 4096, 20]

  validation {
    condition = var.server_specs[1] >= 1 && var.server_specs[1] <= 96  # vCPU
    error_message = "vCPU debe estar entre 1 y 96."
  }

  validation {
    condition = var.server_specs[2] >= 512 && var.server_specs[2] <= 768000  # Memory MB
    error_message = "Memoria debe estar entre 512MB y 768GB."
  }
}
```

## 📊 Técnicas avanzadas

### 🎯 En Recursos

```hcl
# Uso básico de variables
resource "local_file" "basic_config" {
  filename = "${var.app_name}-config.txt"
  content  = templatefile("${path.module}/templates/config.tmpl", {
    app_name    = var.app_name
    environment = var.environment
    port        = var.port
    enabled     = var.enable_monitoring
  })
}

# Uso condicional de variables
resource "local_file" "conditional_config" {
  count = var.environment == "prod" ? 1 : 0

  filename = "${var.app_name}-production.conf"
  content = templatefile("${path.module}/templates/prod-config.tmpl", {
    app_name     = var.app_name
    ssl_enabled  = var.environment == "prod" ? true : var.enable_ssl
    replica_count = var.environment == "prod" ? 3 : 1
  })
}

# Uso dinámico con for_each
resource "local_file" "multi_env_configs" {
  for_each = var.environment_configs

  filename = "${var.app_name}-${each.key}.json"
  content = jsonencode({
    environment   = each.key
    instance_type = each.value.instance_type
    scaling = {
      min = each.value.min_size
      max = each.value.max_size
    }
    features = {
      monitoring = each.key == "prod" ? true : var.enable_monitoring
      ssl        = each.key == "prod" ? true : false
    }
  })
}
```

### 🔄 Interpolación Avanzada y Templates

```hcl
# Template con lógica condicional compleja
resource "local_file" "advanced_config" {
  filename = "app-${var.environment}.conf"
  content = <<-EOF
    # Configuración generada para ${upper(var.app_name)}
    # Entorno: ${title(var.environment)}
    # Generado: ${timestamp()}

    [APPLICATION]
    name = ${var.app_name}
    environment = ${var.environment}
    version = ${lookup(var.application_config, "version", "1.0.0")}

    [RUNTIME]
    language = ${var.application_config.runtime.language}
    memory = ${var.application_config.runtime.memory}MB
    cpu = ${var.application_config.runtime.cpu}

    [DATABASE]
    engine = ${var.application_config.database.engine}
    host = ${var.environment == "prod" ? "prod-db.internal" : "dev-db.local"}
    port = ${var.database_config.port}
    ssl = ${var.database_config.ssl ? "enabled" : "disabled"}
    backups = ${var.application_config.database.backups ? "enabled" : "disabled"}

    [FEATURES]
    %{ if var.application_config.features.monitoring ~}
    monitoring_enabled = true
    monitoring_endpoint = /metrics
    %{ endif ~}

    %{ if var.application_config.features.logging ~}
    logging_enabled = true
    log_level = ${var.environment == "prod" ? "info" : "debug"}
    %{ endif ~}

    %{ if var.application_config.features.caching ~}
    cache_enabled = true
    cache_ttl = ${var.environment == "prod" ? "3600" : "300"}
    %{ endif ~}

    [NETWORKING]
    %{ for zone in var.availability_zones ~}
    availability_zone = ${zone}
    %{ endfor ~}

    vpc_cidr = ${var.application_config.networking.vpc_cidr}
    subnet_count = ${var.application_config.networking.subnet_count}

    [SECURITY]
    %{ for sg in var.security_groups ~}
    security_group = ${sg}
    %{ endfor ~}

    %{ for cidr in var.allowed_cidrs ~}
    # ${cidr.description}
    allowed_cidr = ${cidr.cidr}
    %{ endfor ~}

    [PORTS]
    %{ for port in var.allowed_ports ~}
    allowed_port = ${port}
    %{ endfor ~}
  EOF
}

# Generación dinámica de archivos de configuración por componente
resource "local_file" "component_configs" {
  for_each = toset(["frontend", "backend", "database", "cache"])

  filename = "components/${each.key}-${var.environment}.yaml"
  content = templatefile("${path.module}/templates/${each.key}.yaml.tpl", {
    component   = each.key
    environment = var.environment
    app_name    = var.app_name
    config      = var.application_config

    # Configuración específica por componente
    replicas = {
      frontend = var.environment == "prod" ? 3 : 1
      backend  = var.environment == "prod" ? 2 : 1
      database = 1
      cache    = var.environment == "prod" ? 2 : 1
    }[each.key]

    resources = {
      frontend = { cpu = "100m", memory = "128Mi" }
      backend  = { cpu = "200m", memory = "256Mi" }
      database = { cpu = "500m", memory = "1Gi" }
      cache    = { cpu = "100m", memory = "64Mi" }
    }[each.key]
  })
}
```

### 🧮 Uso de Variables en Expresiones

```hcl
# Cálculos dinámicos basados en variables
resource "local_file" "calculated_config" {
  filename = "calculated-resources.json"
  content = jsonencode({
    # Cálculo de recursos totales
    total_cpu_cores = sum([
      for config in values(var.environment_configs) :
      config.min_size * lookup({
        "t3.micro"  = 1,
        "t3.small"  = 1,
        "t3.medium" = 2,
        "t3.large"  = 2
      }, config.instance_type, 1)
    ])

    # Cálculo de memoria total
    total_memory_gb = sum([
      for config in values(var.environment_configs) :
      config.min_size * lookup({
        "t3.micro"  = 1,
        "t3.small"  = 2,
        "t3.medium" = 4,
        "t3.large"  = 8
      }, config.instance_type, 1)
    ])

    # Cálculo de costos estimados
    monthly_cost_estimate = sum([
      for env, config in var.environment_configs :
      config.min_size * lookup({
        "t3.micro"  = 8.5,
        "t3.small"  = 17.0,
        "t3.medium" = 34.0,
        "t3.large"  = 67.0
      }, config.instance_type, 25.0)
    ])

    # Configuración optimizada por entorno
    optimized_configs = {
      for env, config in var.environment_configs :
      env => merge(config, {
        # Auto-scaling inteligente
        desired_capacity = max(config.min_size,
          env == "prod" ? 3 : 1
        )

        # Features automáticas por entorno
        features_enabled = {
          monitoring = env == "prod" ? true : var.enable_monitoring
          backup     = env == "prod" ? true : false
          encryption = env == "prod" ? true : false
          cdn        = env == "prod" ? true : false
        }
      })
    }
  })
}
```

## 🔧 Troubleshooting de Variables

### ❗ Errores Comunes

#### Error: Variable not defined

```hcl
# ❌ Error
│ Error: Reference to undeclared input variable
│ A variable named "app_name" was referenced but not declared.

# ✅ Solución: Declarar en variables.tf
variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
}
```

#### Error: Invalid value for variable

```hcl
# ❌ Error
│ Error: Invalid value for variable
│ The value "invalid-env" is not valid for variable "environment"

# ✅ Solución: Revisar validaciones
variable "environment" {
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser: dev, staging, o prod."
  }
}
```

#### Error: Type constraint error

```hcl
# ❌ Error
│ Error: Invalid value for input variable
│ Expected a string, but got number.

# ✅ Solución: Usar conversión de tipos
locals {
  port_string = tostring(var.port)  # Convertir number a string
}
```

### 🛠️ Comandos de Debugging

#### Validar Variables

```hcl
# Validar todas las variables
terraform validate

# Ver valores de variables
terraform console
> var.app_name
> local.common_tags
> var.application_config.runtime.memory

# Ver variables de entorno
env | grep TF_VAR_

# Ver plan con variables específicas
terraform plan -var="app_name=debug-app"
```

#### Debugging de Expresiones

```hcl
# En 'terraform console'
> upper(var.app_name)
> length(var.availability_zones)
> keys(var.tags)
> jsonencode(local.common_tags)

# Testing de funciones
> can(regex("^[a-z-]+$", "test-app"))
> try(var.tags.NonExistent, "default")
> formatdate("YYYY-MM-DD", timestamp())
```

#### Inspección de Estado

```hcl
# Ver variables en outputs
terraform output

# Ver estado completo
terraform show

# Inspeccionar recursos específicos
terraform state show local_file.config
```

### 🔍 Técnicas de Debugging Avanzadas

#### Debugging con Outputs

```hcl
# Outputs para debugging
output "debug_info" {
  value = {
    variables = {
      app_name    = var.app_name
      environment = var.environment
      zones       = var.availability_zones
    }
    locals = {
      resource_prefix = local.resource_prefix
      common_tags     = local.common_tags
      current_env     = local.current_env
    }
    computed = {
      validation_results = local.validation_results
      all_validations    = local.all_validations_pass
    }
  }
}

# Output para ver transformaciones
output "transformations" {
  value = {
    original_tags = var.tags
    processed_tags = local.common_tags
    uppercase_tags = local.uppercase_tags
  }
}
```

### Archivos de Debug

```hcl
# Archivo de debug con toda la información
resource "local_file" "debug_output" {
  filename = "debug-${var.environment}.json"
  content = jsonencode({
    timestamp = timestamp()
    variables = {
      app_name           = var.app_name
      environment        = var.environment
      application_config = var.application_config
    }
    locals = {
      resource_prefix    = local.resource_prefix
      current_env        = local.current_env
      infrastructure     = local.infrastructure_config
      validation_results = local.validation_results
    }
    terraform_info = {
      workspace = terraform.workspace
      version   = "1.6+"
    }
  })
}
```

---

## 🎯 Ejercicios Prácticos Avanzados

### 🏆 Ejercicio 1: Sistema de Configuración Multi-Ambiente

```hcl
# Challenge: Implementar estas variables y locals
variable "environments" {
  type = map(object({
    instance_type     = string
    min_replicas      = number
    max_replicas      = number
    enable_monitoring = bool
    backup_retention  = number
    ssl_required      = bool
  }))
}

locals {
  # Generar configuración automática para cada ambiente
  environment_configs = {
    for env, config in var.environments :
    env => merge(config, {
      # Auto-sizing basado en environment
      storage_size = env == "prod" ? 100 : env == "staging" ? 50 : 20

      # Features automáticas
      cdn_enabled = env == "prod"
      waf_enabled = env == "prod"

      # Naming convention
      resource_prefix = "${var.app_name}-${env}"

      # Costos estimados
      monthly_cost = config.min_replicas * lookup({
        "t3.micro"  = 8.5
        "t3.small"  = 17.0
        "t3.medium" = 34.0
      }, config.instance_type, 25.0)
    })
  }
}
```

### 🏆 Ejercicio 2: Validador de Configuración Avanzado

```hcl
# Challenge: Crear validaciones complejas
locals {
  configuration_validation = {
    # Validar que prod tenga configuración robusta
    prod_requirements_met = (
      var.environment == "prod" ? (
        var.application_config.features.monitoring == true &&
        var.application_config.features.backup == true &&
        var.application_config.runtime.memory >= 1024
      ) : true
    )

    # Validar coherencia entre variables
    memory_cpu_ratio = (
      var.application_config.runtime.memory / var.application_config.runtime.cpu
    )
    memory_ratio_valid = (
      local.memory_cpu_ratio >= 256 && local.memory_cpu_ratio <= 2048
    )

    # Validar nombres únicos
    resource_names_unique = length(distinct([
      var.app_name,
      var.application_config.name
    ])) == 2
  }

  all_validations_passed = alltrue(values(local.configuration_validation))
}

# Generar reporte de validación
resource "local_file" "validation_report" {
  filename = "validation-report-${var.environment}.txt"
  content = <<-EOF
    VALIDATION REPORT
    =================

    Environment: ${var.environment}
    Timestamp: ${timestamp()}

    Validation Results:
    %{ for check, result in local.configuration_validation ~}
    ${result ? "✅" : "❌"} ${check}: ${result}
    %{ endfor ~}

    Overall Status: ${local.all_validations_passed ? "✅ PASSED" : "❌ FAILED"}

    %{ if !local.all_validations_passed ~}
    Please fix the failing validations before proceeding.
    %{ endif ~}
  EOF
}
```

### 🏆 Ejercicio 3: Generador de Configuración Dinámica

```hcl
# Challenge: Generar configuraciones para múltiples servicios
variable "microservices" {
  type = map(object({
    port         = number
    language     = string
    memory_mb    = number
    replicas     = number
    dependencies = list(string)
  }))

  default = {
    userservice = {
      port         = 8080
      language     = "java"
      memory_mb    = 512
      replicas     = 2
      dependencies = ["authservice"]
    }

    authservice = {
      port         = 9090
      language     = "nodejs"
      memory_mb    = 256
      replicas     = 1
      dependencies = []
    }
  }
}

locals {
  # Generar configuración para cada microservicio
  service_configs = {
    for service_name, config in var.microservices :
    service_name => {
      # Configuración base
      name = service_name

      # Configuración de red
      internal_url = "http://${service_name}:${config.port}"

      # Configuración de recursos basada en lenguaje
      resources = {
        cpu = config.language == "java" ? "500m" :
              config.language == "python" ? "200m" :
              "100m"
        memory = "${config.memory_mb}Mi"
      }

      # Health checks específicos por lenguaje
      health_check = {
        path = config.language == "java" ? "/actuator/health" :
               config.language == "nodejs" ? "/health" :
               "/healthz"
        port = config.port
      }

      # Variables de entorno automáticas
      environment_vars = merge(
        {
          SERVICE_NAME = service_name
          SERVICE_PORT = tostring(config.port)
          ENVIRONMENT  = var.environment
        },
        # URLs de dependencias
        {
          for dep in config.dependencies :
          "${upper(dep)}_URL" => "http://${dep}:${var.microservices[dep].port}"
        }
      )
    }
  }
}

# Generar archivos de configuración para cada servicio
resource "local_file" "service_configs" {
  for_each = local.service_configs

  filename = "services/${each.key}-config.yaml"
  content = templatefile("${path.module}/templates/service.yaml.tpl", {
    service = each.value
    global_config = {
      app_name    = var.app_name
      environment = var.environment
      tags        = local.common_tags
    }
  })
}
```
