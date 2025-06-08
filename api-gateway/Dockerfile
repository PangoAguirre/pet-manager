FROM openjdk:21-jdk-slim

LABEL maintainer="PetManager Team"
LABEL service="api-gateway"

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=docker

WORKDIR /app

COPY api-gateway/pom.xml ./
COPY api-gateway/.mvn .mvn
COPY api-gateway/mvnw ./

RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY api-gateway/src ./src

RUN ./mvnw clean package -DskipTests

EXPOSE 8080

CMD ["java", "-jar", "/app/target/api-gateway-0.0.1-SNAPSHOT.jar"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1