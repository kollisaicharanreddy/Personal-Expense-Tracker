#!/bin/bash
# Start script for Render.com

echo "🚀 Starting Personal Expense Tracker..."

# Start the application with Railway profile (compatible with Render)
java -Dserver.port=$PORT -Dspring.profiles.active=railway $JAVA_OPTS -jar target/Personal-Expense-Tracker-*.jar