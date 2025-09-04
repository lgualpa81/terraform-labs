# Configuración para el entorno: ${env_name}

variable "${env_name}_region" {
  description = "Región para el entorno ${env_name}"
  default     = "${config.region}"
}

variable "${env_name}_instance_count" {
  description = "Cantidad de instancias para ${env_name}"
  default     = ${config.instance_count}
}

variable "${env_name}_instance_type" {
  description = "Tipo de instancia para ${env_name}"
  default     = "${config.instance_type}"
}

variable "${env_name}_database_size" {
  description = "Tamaño de base de datos para ${env_name}"
  default     = "${config.database_size}"
}

variable "${env_name}_backup_enabled" {
  description = "Backup habilitado para ${env_name}"
  default     = ${config.backup_enabled}
}
