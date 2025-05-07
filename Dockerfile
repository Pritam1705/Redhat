# Base image
FROM maven:3.9.5-eclipse-temurin-17-alpine

# Set working directory inside container
WORKDIR /app

# Copy your code to container (adjust if needed)
COPY . .

# Default command (optional)
CMD ["mvn", "--version"]
