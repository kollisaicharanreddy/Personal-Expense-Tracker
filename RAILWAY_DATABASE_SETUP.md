# Railway Database Setup Instructions

## 🚨 Current Issue: Application Failed to Respond

This means the app builds but fails to start. Most likely cause: **No database provisioned**.

## ✅ Solution Steps:

### Step 1: Add MySQL Database in Railway
1. Go to Railway Dashboard
2. Click your project
3. Click "Add Service" → "Database" → "MySQL"
4. Wait for database to provision

### Step 2: Connect Database to App
1. In Railway, click on your web service
2. Go to "Variables" tab
3. Add these variables:
   - MYSQLHOST (from database service)
   - MYSQLPORT (from database service) 
   - MYSQLUSER (from database service)
   - MYSQLPASSWORD (from database service)
   - MYSQLDATABASE (from database service)

### Step 3: Redeploy
Railway will automatically redeploy with database connection.

## 🔧 Alternative: Use H2 (Current Config)
Current config falls back to H2 in-memory database if MySQL not available.
This should work for testing.

## 📋 Next Steps:
1. Add MySQL database in Railway
2. Connect variables
3. App should start successfully