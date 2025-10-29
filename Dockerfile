# Multi-stage build for smaller image size
# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-alpine AS builder

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml first for better caching
COPY mvnw ./
COPY mvnw.cmd ./
COPY .mvn .mvn
COPY pom.xml ./

# Make mvnw executable and install dos2unix to handle line endings
RUN apk add --no-cache dos2unix && \
    dos2unix mvnw && \
    chmod +x ./mvnw

# Copy source code
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# Verify the JAR file was created and list it for debugging
RUN ls -la target/ && echo "JAR files found:" && find target/ -name "*.jar" -type f

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR from builder stage using wildcard to handle any JAR file
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Set environment variable for Spring profile
ENV SPRING_PROFILES_ACTIVE=render

# Run the application with Spring Boot optimizations
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]