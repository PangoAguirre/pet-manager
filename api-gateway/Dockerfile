FROM openjdk:21-jdk-slim

LABEL maintainer="PetManager Team"
LABEL service="api-gateway"

# Instalar curl para health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Variables de ambiente
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=production

WORKDIR /app

# Copiar archivos Maven
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./

# Hacer ejecutable mvnw
RUN chmod +x mvnw

# Descargar dependencias (cache layer)
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente (incluyendo application-production.yml)
COPY src ./src

# Construir aplicación
RUN ./mvnw clean package -DskipTests

# Exponer puerto (Render usa variable PORT)
EXPOSE $PORT

# Health check usando variable PORT
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:$PORT/actuator/health || exit 1

# Comando de inicio con puerto dinámico
CMD ["sh", "-c", "java $JAVA_OPTS -Dserver.port=$PORT -jar /app/target/api-gateway-0.0.1-SNAPSHOT.jar"]