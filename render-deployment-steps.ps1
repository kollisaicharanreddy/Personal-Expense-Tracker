# Render Deployment Commands
# Execute these after pushing to GitHub

Write-Host "🎯 RENDER DEPLOYMENT - EXACT STEPS" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`n📋 What you'll do in Render Dashboard:" -ForegroundColor Blue
Write-Host "1. Go to: https://dashboard.render.com" -ForegroundColor White
Write-Host "2. Click 'New +' button" -ForegroundColor White

Write-Host "`n🗄️ STEP 1: Create PostgreSQL Database" -ForegroundColor Green
Write-Host "-------------------------------------" -ForegroundColor Green
Write-Host "• Click 'New +' → 'PostgreSQL'" -ForegroundColor White
Write-Host "• Name: personal-expense-tracker-db" -ForegroundColor White  
Write-Host "• Database: personal_expense_tracker" -ForegroundColor White
Write-Host "• User: expense_user" -ForegroundColor White
Write-Host "• Plan: Free" -ForegroundColor White
Write-Host "• Click 'Create Database'" -ForegroundColor White
Write-Host "• ⏳ Wait 2-3 minutes for database to be ready" -ForegroundColor Yellow

Write-Host "`n🌐 STEP 2: Create Backend Web Service" -ForegroundColor Green  
Write-Host "--------------------------------------" -ForegroundColor Green
Write-Host "• Click 'New +' → 'Web Service'" -ForegroundColor White
Write-Host "• Connect your GitHub repository" -ForegroundColor White
Write-Host "• Name: personal-expense-tracker-backend" -ForegroundColor White
Write-Host "• Runtime: Java" -ForegroundColor White
Write-Host "• Build Command: chmod +x render-build.sh && ./render-build.sh" -ForegroundColor White
Write-Host "• Start Command: chmod +x render-start.sh && ./render-start.sh" -ForegroundColor White

Write-Host "`n🔧 Environment Variables for Backend:" -ForegroundColor Yellow
Write-Host "SPRING_PROFILES_ACTIVE=render" -ForegroundColor White
Write-Host "DATABASE_URL=[copy from database service]" -ForegroundColor White  
Write-Host "DB_USERNAME=[copy from database service]" -ForegroundColor White
Write-Host "DB_PASSWORD=[copy from database service]" -ForegroundColor White
Write-Host "CORS_ORIGINS=*" -ForegroundColor White

Write-Host "`n🌐 STEP 3: Create Frontend Static Site" -ForegroundColor Green
Write-Host "--------------------------------------" -ForegroundColor Green  
Write-Host "• Click 'New +' → 'Static Site'" -ForegroundColor White
Write-Host "• Connect same GitHub repository" -ForegroundColor White
Write-Host "• Name: personal-expense-tracker-frontend" -ForegroundColor White
Write-Host "• Root Directory: src/main/resources/static" -ForegroundColor White
Write-Host "• Build Command: [leave empty]" -ForegroundColor White
Write-Host "• Publish Directory: ." -ForegroundColor White

Write-Host "`n🔧 Environment Variables for Frontend:" -ForegroundColor Yellow  
Write-Host "API_URL=https://[your-backend-service].onrender.com" -ForegroundColor White

Write-Host "`n✅ ALTERNATIVE: One-Click Deployment" -ForegroundColor Magenta
Write-Host "------------------------------------" -ForegroundColor Magenta
Write-Host "• Click 'New +' → 'Blueprint'" -ForegroundColor White
Write-Host "• Connect your GitHub repository" -ForegroundColor White  
Write-Host "• Render will automatically read render.yaml" -ForegroundColor White
Write-Host "• All services will be created automatically!" -ForegroundColor White

Write-Host "`n🎯 After Deployment:" -ForegroundColor Blue
Write-Host "• Backend URL: https://personal-expense-tracker-backend.onrender.com" -ForegroundColor White
Write-Host "• Frontend URL: https://personal-expense-tracker-frontend.onrender.com" -ForegroundColor White
Write-Host "• Run verify-deployment.sh to test everything" -ForegroundColor White

Write-Host "`n🚀 Ready for Render deployment!" -ForegroundColor Green