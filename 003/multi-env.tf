locals {
  allowed_envs           = ["dev", "qa", "prod"]
  allowed_regions        = ["us-east-1", "us-west-1", "us-west-2", "eu-west-1"]
  allowed_instance_types = ["t3.micro", "t3.small", "t3.medium", "t3.large"]

  error_instance_type = "Tipos de instancia permitidos: ${join(", ", local.allowed_instance_types)}."
  error_region        = "Regiones permitidas: ${join(", ", local.allowed_regions)}."
  error_envs          = "Ambientes permitidos: ${join(", ", local.allowed_envs)}."
}

variable "environments" {
  type = map(object({
    region         = string
    instance_count = number
    instance_type  = string
    database_size  = string
    backup_enabled = bool
  }))

  default = {
    dev = {
      region         = "us-east-1"
      instance_count = 1
      instance_type  = "t3.micro"
      database_size  = "small"
      backup_enabled = false
    }

    qa = {
      region         = "us-west-2"
      instance_count = 2
      instance_type  = "t3.small"
      database_size  = "medium"
      backup_enabled = true
    }

    prod = {
      region         = "eu-west-1"
      instance_count = 3
      instance_type  = "t3.large"
      database_size  = "large"
      backup_enabled = true
    }
  }

  validation {
    condition = alltrue([
      for env_name in keys(var.environments) : contains(local.allowed_envs, env_name)
    ])
    error_message = local.error_envs
  }

  validation {
    condition = alltrue([
      for env in values(var.environments) : contains(local.allowed_regions, env.region)
    ])
    error_message = local.error_region
  }

  validation {
    condition = alltrue([
      for env in values(var.environments) :
      contains(local.allowed_instance_types, env.instance_type)
    ])
    error_message = local.error_instance_type
  }
}


# Generar archivo por ambiente
resource "local_file" "environment_configs" {
  for_each = var.environments

  filename = "outputs/environments/${each.key}.tf"
  content = templatefile("${path.module}/templates/environment.tpl", {
    env_name = each.key
    config   = each.value
  })
}
