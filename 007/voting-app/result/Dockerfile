# Etapa 1: Construcción
FROM node:20-alpine as builder

# Instalar PNPM globalmente
RUN npm install -g pnpm

# Crear y establecer el directorio de trabajo
WORKDIR /app

# Copiar el archivo de configuración de PNPM (si existe) y el archivo de dependencias
# COPY pnpm-lock.yaml ./
COPY package.json ./

# Instalar las dependencias usando PNPM
# RUN pnpm install --frozen-lockfile
RUN pnpm install

# Copiar el resto de la aplicación al contenedor
COPY . .

# Construir la aplicación (si es necesario)
# RUN pnpm build

# Etapa 2: Imagen de producción
FROM node:20-alpine

# Instalar PNPM globalmente para la etapa de producción también
RUN npm install -g pnpm && apk add curl

# Crear y establecer el directorio de trabajo
WORKDIR /app

# Copiar solo las dependencias necesarias para producción
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml* ./

# Instalar solo las dependencias de producción
RUN pnpm install --prod --frozen-lockfile && \
  pnpm store prune && \
  rm -rf /root/.local/share/pnpm/store

# Copiar los archivos de la aplicación y el build generado
# COPY --from=builder /app/dist /app/dist 
COPY . .

# Exponer el puerto en el que se ejecutará la aplicación (ajustar según sea necesario)
EXPOSE 3000

# Comando para ejecutar la aplicación en producción
CMD ["pnpm", "start"]
