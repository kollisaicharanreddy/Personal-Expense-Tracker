#!/bin/bash
# Render.com build script for Personal Expense Tracker

echo "🚀 Building Personal Expense Tracker for Render..."

# Clean and build the project
./mvnw clean package -DskipTests

echo "✅ Build completed successfully!"