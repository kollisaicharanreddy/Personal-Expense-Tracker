# Personal Expense Tracker - Render Deployment Guide

## 🚀 Render Deployment Instructions

This guide will help you deploy the Personal Expense Tracker to Render.com with PostgreSQL database.

### Prerequisites
- GitHub account with this repository
- Render.com account
- Repository pushed to GitHub

### Step 1: Create PostgreSQL Database on Render

1. **Login to Render Dashboard:** https://dashboard.render.com
2. **Click "New +"** → **"PostgreSQL"**
3. **Configure Database:**
   - **Name:** `personal-expense-tracker-db`
   - **Database:** `personal_expense_tracker`
   - **User:** `expense_user`
   - **Region:** Choose closest to you
   - **Plan:** Free tier
4. **Click "Create Database"**
5. **Wait 2-3 minutes** for database to be ready
6. **Copy connection details** (you'll need these for the web service)

### Step 2: Deploy Backend (Spring Boot) as Web Service

1. **In Render Dashboard, click "New +"** → **"Web Service"**
2. **Connect Repository:** Select your GitHub repository
3. **Configure Web Service:**

   **Basic Settings:**
   - **Name:** `personal-expense-tracker-backend`
   - **Region:** Same as database
   - **Branch:** `main`
   - **Root Directory:** Leave empty (use root)
   - **Runtime:** `Java`
   
   **Build & Deploy:**
   - **Build Command:** `chmod +x render-build.sh && ./render-build.sh`
   - **Start Command:** `chmod +x render-start.sh && ./render-start.sh`
   
   **Advanced:**
   - **Auto-Deploy:** Yes
   - **Plan:** Free tier

4. **Environment Variables:**
   Click "Advanced" → "Add Environment Variable" and add:
   
   ```
   SPRING_PROFILES_ACTIVE=render
   DATABASE_URL=postgresql://[username]:[password]@[host]:[port]/[database]
   DB_USERNAME=[from database connection info]
   DB_PASSWORD=[from database connection info]
   CORS_ORIGINS=*
   ```
   
   **Get these values from your PostgreSQL service created in Step 1**

5. **Click "Create Web Service"**
6. **Wait for deployment** (5-10 minutes)

### Step 3: Deploy Frontend as Static Site

1. **In Render Dashboard, click "New +"** → **"Static Site"**
2. **Connect Repository:** Select same GitHub repository
3. **Configure Static Site:**

   **Basic Settings:**
   - **Name:** `personal-expense-tracker-frontend`
   - **Branch:** `main`
   - **Root Directory:** `src/main/resources/static`
   
   **Build Settings:**
   - **Build Command:** Leave empty (static files)
   - **Publish Directory:** `.` (current directory)

4. **Environment Variables:**
   ```
   API_URL=https://your-backend-service.onrender.com
   ```
   
   **Replace with your actual backend URL from Step 2**

5. **Click "Create Static Site"**

### Step 4: Test Your Deployment

1. **Backend Health Check:**
   ```bash
   curl https://your-backend-service.onrender.com/api/categories
   ```

2. **Frontend Access:**
   Open: `https://your-frontend-service.onrender.com`

3. **Full Functionality Test:**
   - Open frontend URL
   - Add a new expense
   - Verify it appears in the list
   - Check backend logs in Render dashboard

### Step 5: Update Frontend API URL

1. **Edit `src/main/resources/static/script.js`**
2. **Find the API base URL** (usually near the top)
3. **Update it to your backend URL:**
   ```javascript
   const API_BASE_URL = 'https://your-backend-service.onrender.com/api';
   ```
4. **Commit and push** - Render will auto-deploy

### Troubleshooting

#### Common Issues:

**Backend fails to start:**
- Check environment variables are set correctly
- Verify PostgreSQL connection string format
- Check Render logs for specific errors

**Database connection errors:**
- Ensure DATABASE_URL format: `postgresql://username:password@host:port/database`
- Verify database is running and accessible
- Check credentials match database settings

**CORS errors:**
- Verify backend CORS configuration includes frontend URL
- Check browser developer console for specific errors

**Frontend can't connect to backend:**
- Verify API_URL points to correct backend service
- Check if backend is running and accessible
- Ensure API endpoints return expected data

#### Getting Help:

1. **Check Render Logs:**
   - Go to your service in Render dashboard
   - Click "Logs" tab
   - Look for error messages

2. **Render Support:**
   - Documentation: https://render.com/docs
   - Community: https://community.render.com

### Service URLs

After successful deployment, you'll have:

- **Backend API:** `https://personal-expense-tracker-backend.onrender.com`
- **Frontend Web App:** `https://personal-expense-tracker-frontend.onrender.com`
- **Database:** Internal Render PostgreSQL instance

### Environment Variables Reference

**Backend Service:**
```
SPRING_PROFILES_ACTIVE=render
DATABASE_URL=postgresql://[username]:[password]@[host]:[port]/[database]
DB_USERNAME=[database_username]
DB_PASSWORD=[database_password]
CORS_ORIGINS=*
```

**Frontend Service:**
```
API_URL=https://your-backend-service.onrender.com
```

### Maintenance

- **Logs:** Monitor via Render dashboard
- **Updates:** Push to GitHub main branch for auto-deploy
- **Scaling:** Upgrade plan if needed for production use
- **Monitoring:** Use Render's built-in monitoring tools

---

## 🎉 Deployment Complete!

Your Personal Expense Tracker is now live on Render with:
- ✅ PostgreSQL database
- ✅ Spring Boot backend API
- ✅ Static frontend
- ✅ Automatic deployments

**Happy expense tracking!** 💰