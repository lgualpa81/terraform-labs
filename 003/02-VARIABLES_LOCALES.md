Los locals son variables calculadas que transforman y combinan datos. Son el cerebro de tu configuración.

🧮 ¿Por qué usar Locals?

- 🚀 Performance: Se calculan una vez, se usan muchas veces
- 🎯 Claridad: Simplifican expresiones complejas
- 🔄 Reutilización: Un cálculo, múltiples usos
- 🛡️ Mantenibilidad: Centralizan la lógica de negocio

### 🎯 Locals Básicos

```hcl
locals {
  # 🏷️ Naming conventions automatizadas
  resource_prefix = "${var.app_name}-${var.environment}"
  dns_name        = "${var.app_name}.${var.environment}.company.com"

  # 📅 Timestamps inteligentes
  creation_timestamp = timestamp()
  readable_date      = formatdate("YYYY-MM-DD", timestamp())
  unique_suffix      = formatdate("YYYYMMDD-hhmm", timestamp())

  # 🏷️ Tags estandarizados
  common_tags = merge(var.tags, {
    Terraform     = "true"
    Environment   = var.environment
    Application   = var.app_name
    CreatedDate   = local.readable_date
    ResourceGroup = local.resource_prefix
  })

  # 🔄 Transformaciones de datos
  uppercase_tags = {
    for key, value in local.common_tags :
    upper(key) => upper(value)
  }

  # 📊 Configuraciones por entorno
  env_settings = {
    dev = {
      instance_type    = "t3.micro"
      min_replicas     = 1
      max_replicas     = 2
      enable_logging   = true
      enable_monitoring = false
      backup_retention = 7
    }
    staging = {
      instance_type    = "t3.small"
      min_replicas     = 2
      max_replicas     = 4
      enable_logging   = true
      enable_monitoring = true
      backup_retention = 14
    }
    prod = {
      instance_type    = "t3.medium"
      min_replicas     = 3
      max_replicas     = 10
      enable_logging   = true
      enable_monitoring = true
      backup_retention = 30
    }
  }

  # 🎯 Configuración actual automática
  current_env = local.env_settings[var.environment]
}
```

### 🧮 Locals Avanzados

```hcl
locals {
  # 🏗️ Configuración de infraestructura inteligente
  infrastructure_config = {
    # Auto-dimensionamiento basado en entorno
    compute = {
      instance_type = local.current_env.instance_type
      desired_capacity = local.current_env.min_replicas

      # Optimización automática de recursos
      cpu_credits = startswith(local.current_env.instance_type, "t3") ? "unlimited" : null

      # Configuración de storage por tipo de instancia
      root_volume_size = lookup({
        "t3.micro"  = 8
        "t3.small"  = 10
        "t3.medium" = 15
        "t3.large"  = 20
      }, local.current_env.instance_type, 10)
    }

    # Red inteligente basada en número de AZs
    networking = {
      vpc_cidr = "10.${var.environment == "prod" ? 0 : var.environment == "staging" ? 1 : 2}.0.0/16"

      # Subnets automáticas
      public_subnets = [
        for i, az in var.availability_zones :
        "10.${var.environment == "prod" ? 0 : var.environment == "staging" ? 1 : 2}.${i + 1}.0/24"
      ]

      private_subnets = [
        for i, az in var.availability_zones :
        "10.${var.environment == "prod" ? 0 : var.environment == "staging" ? 1 : 2}.${i + 10}.0/24"
      ]

      # NAT Gateways inteligentes
      enable_nat_gateway = var.environment == "prod" ? true : false
      single_nat_gateway = var.environment != "prod" ? true : false
    }

    # Base de datos optimizada
    database = merge(var.database_config, {
      # Tamaño automático basado en entorno
      allocated_storage = {
        dev     = 20
        staging = 50
        prod    = 100
      }[var.environment]

      # Configuración de backup inteligente
      backup_retention_period = local.current_env.backup_retention
      backup_window          = var.environment == "prod" ? "03:00-04:00" : "02:00-03:00"
      maintenance_window     = var.environment == "prod" ? "sun:04:00-sun:05:00" : "sun:03:00-sun:04:00"

      # Multi-AZ solo en producción
      multi_az = var.environment == "prod" ? true : false

      # Tipo de instancia optimizado
      instance_class = {
        dev     = "db.t3.micro"
        staging = "db.t3.small"
        prod    = "db.r5.large"
      }[var.environment]
    })
  }

  # 🔐 Configuración de seguridad dinámica
  security_config = {
    # Reglas de firewall inteligentes
    ingress_rules = concat(
      # HTTP/HTTPS básico
      [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS access"
        }
      ],

      # SSH solo para no-producción o con restricciones
      var.environment != "prod" ? [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
          description = "SSH access from internal network"
        }
      ] : [],

      # Puertos de aplicación personalizados
      [
        for port in var.allowed_ports : {
          from_port   = port
          to_port     = port
          protocol    = "tcp"
          cidr_blocks = [local.infrastructure_config.networking.vpc_cidr]
          description = "Application port ${port}"
        }
      ],

      # Acceso a base de datos solo desde VPC
      [
        {
          from_port   = var.database_config.port
          to_port     = var.database_config.port
          protocol    = "tcp"
          cidr_blocks = [local.infrastructure_config.networking.vpc_cidr]
          description = "Database access from VPC"
        }
      ]
    )

    # Encriptación automática por entorno
    encryption_config = {
      ebs_encrypted          = var.environment == "prod" ? true : false
      s3_sse_algorithm      = var.environment == "prod" ? "aws:kms" : "AES256"
      rds_storage_encrypted = var.environment == "prod" ? true : false
    }
  }

  # 📊 Cálculos de costos y recursos
  cost_analysis = {
    # Estimación mensual por servicio
    monthly_costs = {
      compute = local.current_env.min_replicas * lookup({
        "t3.micro"  = 8.5
        "t3.small"  = 17.0
        "t3.medium" = 34.0
        "t3.large"  = 67.0
      }, local.current_env.instance_type, 25.0)

      database = lookup({
        "db.t3.micro" = 15.0
        "db.t3.small" = 30.0
        "db.r5.large" = 182.0
      }, local.infrastructure_config.database.instance_class, 50.0)

      storage = local.infrastructure_config.database.allocated_storage * 0.115

      network = var.environment == "prod" ? 45.0 : 15.0
    }

    total_monthly_estimate = sum(values(local.cost_analysis.monthly_costs))

    # Recursos totales calculados
    total_resources = {
      vcpus = local.current_env.min_replicas * lookup({
        "t3.micro"  = 1
        "t3.small"  = 1
        "t3.medium" = 2
        "t3.large"  = 2
      }, local.current_env.instance_type, 1)

      memory_gb = local.current_env.min_replicas * lookup({
        "t3.micro"  = 1
        "t3.small"  = 2
        "t3.medium" = 4
        "t3.large"  = 8
      }, local.current_env.instance_type, 2)

      storage_gb = local.current_env.min_replicas * local.infrastructure_config.compute.root_volume_size
    }
  }

  # 🎛️ Features dinámicas habilitadas
  enabled_features = {
    monitoring = local.current_env.enable_monitoring || var.enable_monitoring
    logging    = local.current_env.enable_logging
    backup     = var.environment != "dev"
    cdn        = var.environment == "prod"
    waf        = var.environment == "prod"

    # Auto-scaling inteligente
    auto_scaling = {
      enabled     = local.current_env.max_replicas > local.current_env.min_replicas
      min_size    = local.current_env.min_replicas
      max_size    = local.current_env.max_replicas
      target_cpu  = var.environment == "prod" ? 70 : 80
    }
  }
}
```

### 📋 Ejemplo de Uso de Locals en Recursos

```hcl
# Archivo de configuración de infraestructura completa
resource "local_file" "infrastructure_summary" {
  filename = "${local.resource_prefix}-infrastructure.json"
  content = jsonencode({
    project_info = {
      name         = var.app_name
      environment  = var.environment
      created_at   = local.creation_timestamp
      resource_prefix = local.resource_prefix
    }

    infrastructure = local.infrastructure_config
    security       = local.security_config
    cost_analysis  = local.cost_analysis
    features       = local.enabled_features
    components     = local.application_components
  })
}

# Archivo de configuración por componente
resource "local_file" "component_configs" {
  for_each = local.application_components

  filename = "components/${each.key}-${var.environment}.yaml"
  content = templatefile("${path.module}/templates/component.yaml.tpl", {
    component_name = each.key
    component_config = each.value
    environment = var.environment
    tags = local.common_tags
    security_group = local.security_groups[each.key]
  })
}

# Terraform workspace summary
resource "local_file" "workspace_summary" {
  filename = "${local.resource_prefix}-summary.txt"
  content = <<-EOF
    🚀 TERRAFORM WORKSPACE SUMMARY
    ================================

    📋 PROJECT INFORMATION
    Name: ${var.app_name}
    Environment: ${upper(var.environment)}
    Created: ${local.readable_date}
    Resource Prefix: ${local.resource_prefix}

    🏗️ INFRASTRUCTURE
    VPC CIDR: ${local.infrastructure_config.networking.vpc_cidr}
    Instance Type: ${local.infrastructure_config.compute.instance_type}
    Min Replicas: ${local.current_env.min_replicas}
    Max Replicas: ${local.current_env.max_replicas}

    💾 DATABASE
    Engine: ${var.database_config.engine}
    Instance Class: ${local.infrastructure_config.database.instance_class}
    Storage: ${local.infrastructure_config.database.allocated_storage}GB
    Multi-AZ: ${local.infrastructure_config.database.multi_az}

    🎛️ FEATURES ENABLED
    %{ for feature, enabled in local.enabled_features ~}
    %{ if enabled ~}
    ✅ ${title(feature)}
    %{ endif ~}
    %{ endfor ~}

    📊 RESOURCE ALLOCATION
    Total vCPUs: ${local.cost_analysis.total_resources.vcpus}
    Total Memory: ${local.cost_analysis.total_resources.memory_gb}GB
    Total Storage: ${local.cost_analysis.total_resources.storage_gb}GB

    💰 COST ESTIMATION (Monthly)
    Compute: $${local.cost_analysis.monthly_costs.compute}
    Database: $${local.cost_analysis.monthly_costs.database}
    Storage: $${local.cost_analysis.monthly_costs.storage}
    Network: $${local.cost_analysis.monthly_costs.network}
    ──────────────────────────────
    TOTAL: $${local.cost_analysis.total_monthly_estimate}

    🏷️ COMMON TAGS
    %{ for key, value in local.common_tags ~}
    ${key}: ${value}
    %{ endfor ~}

    ──────────────────────────────
    Generated by Terraform 🤖
  EOF
}
```

## 🎯 Mejores Prácticas para Variables

### 📋 Naming Conventions

```hcl
# ✅ BUENAS PRÁCTICAS
variable "app_name" {              # ✅ snake_case
  description = "Nombre de la aplicación"  # ✅ Descripción clara
  type        = string             # ✅ Tipo explícito

  validation {                     # ✅ Validación incluida
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.app_name))
    error_message = "app_name debe seguir convenciones de naming."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev/staging/prod)"  # ✅ Opciones claras
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser: dev, staging, o prod."
  }
}

# ❌ MALAS PRÁCTICAS
variable "AppName" { }             # ❌ PascalCase
variable "app-name" { }            # ❌ kebab-case
variable "APPNAME" { }             # ❌ UPPERCASE
variable "a" { }                   # ❌ Nombre no descriptivo
```

🏗️ Organización de Variables

```hcl
# variables.tf - Organizado por categorías

# ======================
# CONFIGURACIÓN BÁSICA
# ======================
variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
  # ... configuración
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  # ... configuración
}

# ======================
# CONFIGURACIÓN DE RED
# ======================
variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  # ... configuración
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  # ... configuración
}

# ======================
# CONFIGURACIÓN DE APLICACIÓN
# ======================
variable "application_config" {
  description = "Configuración completa de la aplicación"
  type = object({
    runtime = object({
      language = string
      version  = string
      memory   = number
      cpu      = number
    })
    # ... más configuración
  })
}

# ======================
# CONFIGURACIÓN SENSIBLE
# ======================
variable "database_password" {
  description = "Password de la base de datos"
  type        = string
  sensitive   = true
  # ... configuración
}
```

### 🔒 Manejo de Variables Sensibles

```hcl
# Variables marcadas como sensitive
variable "api_key" {
  description = "API key para servicios externos"
  type        = string
  sensitive   = true  # ✅ No aparece en logs
}

variable "database_credentials" {
  description = "Credenciales de base de datos"
  type = object({
    username = string
    password = string
  })
  sensitive = true  # ✅ Todo el objeto es sensitive
}

# Uso de variables sensibles
resource "local_file" "app_config" {
  content = templatefile("${path.module}/templates/config.tpl", {
    api_key = var.api_key
    # La variable sensible se puede usar normalmente
  })

  lifecycle {
    ignore_changes = [content]  # ✅ Evita cambios accidentales
  }
}
```

### 🎛️ Valores Por Defecto Inteligentes

```hcl
variable "instance_config" {
  description = "Configuración de instancias"
  type = object({
    type  = optional(string, "t3.micro")      # ✅ Valor por defecto
    count = optional(number)                  # ✅ Sin valor por defecto (requerido cuando se usa)
  })
  default = {}  # ✅ Objeto vacío permite usar solo valores por defecto
}

variable "features" {
  description = "Features de la aplicación"
  type = object({
    monitoring = optional(bool, true)         # ✅ Habilitado por defecto
    backup     = optional(bool, false)       # ✅ Deshabilitado por defecto
    ssl        = optional(bool, true)        # ✅ Habilitado por defecto
  })
  default = {}
}

# Uso con coalesce para fallbacks múltiples
locals {
  final_instance_type = coalesce(
    var.instance_config.type,
    var.environment == "prod" ? "t3.medium" : "t3.micro",
    "t3.micro"  # último fallback
  )
}
```

```hcl

```
