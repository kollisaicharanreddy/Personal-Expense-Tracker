#!/bin/bash
# Render.com start script for Personal Expense Tracker

echo "🚀 Starting Personal Expense Tracker on Render..."

# Set the profile for Render
export SPRING_PROFILES_ACTIVE=render

# Start the application
java -Dserver.port=$PORT -Dspring.profiles.active=render $JAVA_OPTS -jar target/Personal-Expense-Tracker-*.jar