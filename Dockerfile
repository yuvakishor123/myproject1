# Step 1: Use Maven image to build artifact
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Step 2: Use lightweight JDK image to run artifact
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY --from=build /app/target/demo-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

