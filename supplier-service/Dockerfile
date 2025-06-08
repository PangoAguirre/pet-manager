FROM openjdk:21-jdk-slim

LABEL maintainer="PetManager Team"
LABEL service="supplier-service"

# Instalar curl para health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=production

WORKDIR /app

# Copiar archivos Maven
COPY supplier-service/pom.xml ./
COPY supplier-service/.mvn .mvn
COPY supplier-service/mvnw ./

# Hacer ejecutable mvnw
RUN chmod +x mvnw

# Descargar dependencias (cache layer)
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente
COPY supplier-service/src ./src

# Construir aplicación
RUN ./mvnw clean package -DskipTests

# Exponer puerto
EXPOSE 8082

# Health check corregido (cambiar de /api/health a /actuator/health)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8082/actuator/health || exit 1

# Comando de inicio
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/target/supplier-service-0.0.1-SNAPSHOT.jar"]