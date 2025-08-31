# Conceptos básicos

### 1. Providers 🔌

```bash
# Provider para AWS
provider "aws" {
  region = "us-east-1"
}

# Provider para Docker
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Provider para Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Provider para múltiples clouds
provider "azurerm" {
  features {}
}
```

### 2. Resources 🏗️

```bash
# Sintaxis general
resource "tipo_provider_recurso" "nombre_local" {
  argumento1 = "valor1"
  argumento2 = "valor2"

  # Bloque anidado
  configuracion {
    opcion = "valor"
  }

  # Meta-argumentos
  depends_on = [otro_recurso.ejemplo]
  count      = 3

  # Lifecycle
  lifecycle {
    prevent_destroy = true
  }
}
```

### 3. State Management 💾

```bash
# ¿Qué contiene el estado?
✅ Mapeo entre configuración y recursos reales
✅ Metadatos de recursos
✅ Dependencias entre recursos
✅ Configuración de providers

# ¿Por qué es importante?
✅ Detecta cambios (drift detection)
✅ Optimiza operaciones (parallelization)
✅ Permite rollbacks seguros
✅ Habilita colaboración en equipo
```

### Comandos de estado

```bash
# Backup manual del estado
cp terraform.tfstate terraform.tfstate.backup

# Importar recurso existente
terraform import aws_instance.example i-1234567890abcdef0

# Remover recurso del estado (sin destruir)
terraform state rm aws_instance.example

# Mover recurso en el estado
terraform state mv aws_instance.old aws_instance.new

# Actualizar estado con infraestructura real
terraform refresh
```

### 4. Variables y Tipos 📝

```bash
# Tipos básicos
variable "string_example" {
  type    = string
  default = "hello"
}

variable "number_example" {
  type    = number
  default = 42
}

variable "bool_example" {
  type    = bool
  default = true
}

# Tipos complejos
variable "list_example" {
  type    = list(string)
  default = ["item1", "item2", "item3"]
}

variable "map_example" {
  type = map(string)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}

variable "object_example" {
  type = object({
    name    = string
    age     = number
    active  = bool
  })
  default = {
    name   = "example"
    age    = 30
    active = true
  }
}
```

### 5. Data Sources 📊

```bash
# Consultar AMI más reciente
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Usar data source en recurso
resource "aws_instance" "example" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
}
```

# Comandos básicos

### 1. Inicialización 🚀

```bash
# Inicializar el directorio de trabajo
terraform init

# Reinicializar forzando descarga de providers
terraform init -upgrade

# Inicializar con backend específico
terraform init -backend-config="bucket=my-tf-state"
```

### 2. Validación ✅

```bash
# Validar sintaxis de configuración
terraform validate

# Formatear código automáticamente
terraform fmt

# Formatear recursivamente
terraform fmt -recursive

# Solo verificar formato (sin cambiar)
terraform fmt -check
```

### 3. Planificación 📋

```bash
# Ver qué cambios se aplicarán
terraform plan

# Guardar plan en archivo
terraform plan -out=tfplan

# Plan con variables específicas
terraform plan -var="student_name=devops"

# Plan con archivo de variables
terraform plan -var-file="prod.tfvars"

# Plan mostrando solo cambios
terraform plan -compact-warnings
```

### 4. Aplicación 🚀

```bash
# Aplicar cambios (pide confirmación)
terraform apply

# Aplicar sin confirmación
terraform apply -auto-approve

# Aplicar plan guardado
terraform apply tfplan

# Aplicar con variables
terraform apply -var="student_name=TuNombre"
```

### 5. Inspección 🔍

```bash
# Ver estado actual
terraform show

# Listar recursos en estado
terraform state list

# Ver detalles de un recurso
terraform state show local_file.devops_journey

# Ver outputs
terraform output

# Ver output específico
terraform output generated_files
```

### 6. Destrucción 🗑️

```bash
# Destruir todos los recursos
terraform destroy

# Destruir sin confirmación
terraform destroy -auto-approve

# Destruir recursos específicos
terraform destroy -target=local_file.terraform_config
```
