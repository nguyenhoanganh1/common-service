# Use the official OpenJDK base image for Java 11
FROM openjdk:11-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Gradle build files and settings
COPY build.gradle .
COPY settings.gradle .

# Copy the source code and resources
COPY src ./src

# Build the application using Gradle
RUN ./gradlew build

# Set the entry point to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "build/libs/common-service-0.0.1-SNAPSHOT.jar"]