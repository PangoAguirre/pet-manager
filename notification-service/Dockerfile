FROM openjdk:21-jdk-slim

LABEL maintainer="PetManager Team"
LABEL service="notification-service"

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=docker

WORKDIR /app

COPY notification-service/pom.xml ./
COPY notification-service/.mvn .mvn
COPY notification-service/mvnw ./

RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY notification-service/src ./src

RUN ./mvnw clean package -DskipTests

EXPOSE 8083

CMD ["java", "-jar", "/app/target/notification-service-0.0.1-SNAPSHOT.jar"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8083/actuator/health || exit 1