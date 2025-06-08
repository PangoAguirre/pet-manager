FROM openjdk:21-jdk-slim

LABEL maintainer="PetManager Team"
LABEL service="api-gateway"

# Instalar curl para health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=production

WORKDIR /app

# Copiar archivos Maven
COPY api-gateway/pom.xml ./
COPY api-gateway/.mvn .mvn
COPY api-gateway/mvnw ./

# Hacer ejecutable mvnw
RUN chmod +x mvnw

# Descargar dependencias (cache layer)
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente (incluyendo application-production.yml)
COPY api-gateway/src ./src

# Construir aplicación
RUN ./mvnw clean package -DskipTests

# Exponer puerto
EXPOSE 8080

# Health check corregido
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando de inicio
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/target/api-gateway-0.0.1-SNAPSHOT.jar"]