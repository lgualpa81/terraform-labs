## 🧩 ¿Qué son los Módulos?

Los módulos en Terraform son:

- 📦 Contenedores de múltiples recursos que se usan juntos
- 🔄 Componentes reutilizables de infraestructura
- 🏗️ Abstracciones que simplifican configuraciones complejas
- 📚 Bibliotecas de mejores prácticas

### Tipos de Módulos

1. **Root Module:** El directorio principal donde ejecutas Terraform
2. **Child Modules:** Módulos llamados por otros módulos
3. **Published Modules:** Módulos compartidos en registros públicos

## 🏗️ Estructura de un Módulo

Un módulo típico tiene esta estructura:

```hcl
modules/
└── webapp/
    ├── main.tf          # Recursos principales
    ├── variables.tf     # Variables de entrada
    ├── outputs.tf       # Valores de salida
    ├── versions.tf      # Requisitos de versión
    ├── README.md        # Documentación
    └── examples/        # Ejemplos de uso
        └── basic/
            ├── main.tf
            └── variables.tf
```

**Módulos para equipos**

```hcl
terraform-modules/
├── modules/
│   ├── networking/
│   │   ├── vpc/
│   │   ├── security-groups/
│   │   └── load-balancer/
│   ├── compute/
│   │   ├── webapp/
│   │   ├── database/
│   │   └── cache/
│   └── shared/
│       ├── monitoring/
│       └── logging/
├── examples/
│   ├── dev-environment/
│   └── prod-environment/
└── README.md
```

Esta estructura permite a los equipos compartir y reutilizar módulos para diferentes propósitos (red, cómputo, almacenamiento, seguridad, etc.), facilitando la colaboración y el mantenimiento.

---

## ✅ Buenas Prácticas con Módulos

- Documenta cada módulo con un `README.md` claro.
- Usa nombres descriptivos para variables y outputs.
- Versiona tus módulos y usa tags en Git.
- Mantén los módulos pequeños y enfocados en una sola responsabilidad.
- Usa validaciones en variables para evitar errores comunes.
- Proporciona ejemplos de uso en la carpeta `examples/`.
- Publica módulos útiles en el Terraform Registry si pueden servir a otros.
