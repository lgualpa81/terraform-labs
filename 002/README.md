### 1. Inicializar Terraform

terraform init

### 2. Validar configuración

terraform validate

### 3. Formatear código

terraform fmt

### 4. Ver plan de ejecución

terraform plan

### 5. Aplicar configuración

terraform apply

### 6. Explorar archivos generados

ls -la
cat outputs/README.md
cat outputs/project-config.json | jq .
cat outputs/progress-report.txt

### 7. Ver outputs

terraform output

### 8. Ver output específico

terraform output learning_stats

# Cambiar variables y re-aplicar

terraform apply -var="student_name=TuNuevoNombre"

# Deshabilitar algunos archivos

terraform apply -var='generate_files={"readme"=true,"config"=false,"progress"=true,"roadmap"=false}'

# Ver el estado actual

terraform show

# Destruir cuando termines

terraform destroy
