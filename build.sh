#!/bin/bash
# Build script for Render.com

echo "🚀 Building Personal Expense Tracker for Render..."

# Clean and build the project
./mvnw clean package -DskipTests

echo "✅ Build completed successfully!"