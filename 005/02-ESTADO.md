## 📊 ¿Qué es el Estado de Terraform?

El estado (`terraform.tfstate`) es un archivo que Terraform usa para:

- 🗺️ Recordar qué recursos ha creado
- 🔍 Mapear tu código con la infraestructura real
- 🚀 Optimizar operaciones (sabe qué cambiar)
- 🔄 Detectar cambios externos

```hcl
# Crear un recurso simple
echo 'resource "local_file" "example" {
  filename = "hello.txt"
  content  = "Hello from Terraform!"
}' > main.tf

# Aplicar
terraform init
terraform apply

# Ver el estado
terraform show
cat terraform.tfstate
```

El archivo `terraform.tfstate` contiene información como:

```hcl
{
  "version": 4,
  "terraform_version": "1.6.0",
  "resources": [
    {
      "type": "local_file",
      "name": "example",
      "instances": [
        {
          "attributes": {
            "filename": "hello.txt",
            "content": "Hello from Terraform!"
          }
        }
      ]
    }
  ]
}
```

---

## ⚠️ Problemas del Estado Local

### 1. No se puede compartir

```hcl
# ❌ Problema: Solo en tu máquina
# Tu compañero no puede ver qué has desplegado
# No pueden trabajar juntos en el mismo proyecto
```

### 2. Se puede perder

```hcl
# ❌ Problema: Si borras el archivo por error
rm terraform.tfstate
terraform plan  # Ya no sabe qué recursos existen!
```

### 3. Conflictos en equipo

```hcl
# ❌ Problema: Dos personas ejecutan terraform al mismo tiempo
# Persona A: terraform apply (modificando estado)
# Persona B: terraform apply (modificando estado al mismo tiempo)
# = Estado corrupto
```

---

## 🏢 Workspaces: Múltiples Ambientes

Los `workspaces` permiten tener `múltiples estados` en el mismo código:

### Conceptos Básicos

```hcl
# Ver workspace actual
terraform workspace show
# Output: default

# Listar todos los workspaces
terraform workspace list
# Output:
# * default

# Crear nuevo workspace para desarrollo
terraform workspace new dev
# Output: Created and switched to workspace "dev"!

# Crear workspace para producción
terraform workspace new prod

# Cambiar entre workspaces
terraform workspace select dev
terraform workspace select prod
terraform workspace select default

# Eliminar workspace
terraform workspace delete prod
# Deleted workspace "prod"!
```

### Probando los Workspaces

```hcl
# Workspace de desarrollo
terraform workspace select dev
terraform apply
cat app-dev.conf

# Workspace de producción
terraform workspace select prod
terraform apply
cat app-prod.conf

# Ver las diferencias
terraform workspace select dev
terraform output

terraform workspace select prod
terraform output
```

## 🎮 Probando Múltiples Ambientes

### 1. Desarrollo

```hcl
# Crear y usar workspace dev
terraform workspace new dev
terraform init
terraform apply

# Verificar
terraform output
curl http://localhost:8080
docker ps --filter label=environment=dev
```

### 2. Staging

```hcl
# Cambiar a staging
terraform workspace new staging
terraform apply

# Verificar - nota el puerto diferente
terraform output
curl http://localhost:8081
docker ps --filter label=environment=staging
```

### 3. Producción

```hcl
# Cambiar a producción
terraform workspace new prod
terraform apply

# Verificar - 3 contenedores, puerto 80
terraform output
curl http://localhost:80
docker ps --filter label=environment=prod
```

### 4. Ver todo junto

```hcl
# Ver todos los contenedores de todos los ambientes
docker ps --filter label=managed-by=terraform

# Ver workspaces
terraform workspace list

# Limpiar ambiente específico
terraform workspace select dev
terraform destroy

# Los otros ambientes siguen funcionando
terraform workspace select prod
terraform show
```

---

## 🤝 Colaboración en Equipo (Conceptos)

### Estado Compartido Simple

#### Usando un Directorio Compartido

```hcl
# En versions.tf
terraform {
  backend "local" {
    path = "/shared/projects/mi-app/terraform.tfstate"
  }
}
```

#### Estructura para Equipo

```bash
proyecto-equipo/
├── shared-state/           # Directorio compartido en red
│   ├── dev.tfstate
│   ├── staging.tfstate
│   └── prod.tfstate
├── environments/           # Configuraciones por ambiente
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── scripts/               # Scripts del equipo
│   ├── deploy-dev.sh
│   ├── deploy-staging.sh
│   └── status.sh
├── main.tf
├── variables.tf
└── README.md              # Documentación del equipo
```

---

## 📝 Scripts para Colaboración

### scripts/deploy-dev.sh

```sh
#!/bin/bash
echo "🚀 Desplegando a desarrollo..."

# Cambiar al workspace correcto
terraform workspace select dev || terraform workspace new dev

# Aplicar con variables específicas
terraform apply -var-file="environments/dev.tfvars"

echo "✅ Desarrollo desplegado!"
echo "🌐 URL: http://localhost:8080"

```

### scripts/status.sh

```sh
#!/bin/bash
echo "📊 Estado de todos los ambientes"
echo "================================"

for env in dev staging prod; do
    echo ""
    echo "🏷️ Ambiente: $env"

    if terraform workspace select $env 2>/dev/null; then
        echo "   Estado: $(terraform workspace show)"

        # Verificar si hay recursos
        resource_count=$(terraform state list 2>/dev/null | wc -l)
        echo "   Recursos: $resource_count"

        # Verificar contenedores
        containers=$(docker ps -q --filter label=environment=$env | wc -l)
        echo "   Contenedores activos: $containers"
    else
        echo "   ❌ Workspace no existe"
    fi
done
```

### environments/dev.tfvars

```hcl
# Configuración para desarrollo
app_name = "voting-app"

# Las configuraciones específicas están en locals
# Este archivo puede tener overrides si es necesario
```

---

## 🚨 Buenas Prácticas

### 1. Naming Conventions

```hcl
# ✅ Nombres consistentes
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# ❌ Evitar nombres confusos
terraform workspace new development-environment-v2
```

### 2. Documentación

```sh
# README.md del proyecto

## Ambientes Disponibles

- **dev**: Desarrollo local (puerto 8080)
- **staging**: Testing (puerto 8081)
- **prod**: Producción (puerto 80)

## Comandos Rápidos

# Desplegar a dev
./scripts/deploy-dev.sh

# Ver estado
./scripts/status.sh

# Cambiar ambiente
terraform workspace select [dev|staging|prod]
```

### 3. Estado Seguro

```sh
# ✅ Hacer backups regularmente
cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d)

# ✅ No versionar archivos .tfstate
echo "*.tfstate*" >> .gitignore
echo ".terraform/" >> .gitignore

# ✅ Usar workspaces para separar ambientes
terraform workspace select prod  # Solo para prod
```

---

## 🛠️ Comandos Útiles para el Día a Día

### Gestión de Workspaces

```sh
# Ver workspace actual
terraform workspace show

# Listar workspaces
terraform workspace list

# Crear workspace
terraform workspace new nombre

# Cambiar workspace
terraform workspace select nombre

# Eliminar workspace (debe estar vacío)
terraform workspace delete nombre
```

### Verificación de Estado

```sh
# Ver recursos en el workspace actual
terraform state list

# Ver detalles de un recurso
terraform state show docker_container.app[0]

# Ver toda la configuración aplicada
terraform show

# Ver outputs
terraform output
terraform output app_info
```

### Debugging

```sh
# Verificar qué workspace estás usando
echo "Workspace actual: $(terraform workspace show)"

# Ver el plan antes de aplicar
terraform plan

# Aplicar solo recursos específicos
terraform apply -target=docker_container.app

# Ver logs detallados
TF_LOG=INFO terraform apply
```
