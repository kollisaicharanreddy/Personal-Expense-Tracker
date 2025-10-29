# PowerShell script to push Render deployment files to GitHub
# Run this script from your project directory

Write-Host "🚀 Pushing Personal Expense Tracker to GitHub for Render Deployment" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Not a git repository. Initializing..." -ForegroundColor Yellow
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Git repository found" -ForegroundColor Green
}

# Check git status
Write-Host "`n📋 Current git status:" -ForegroundColor Blue
git status --short

# Add all files
Write-Host "`n📦 Adding all files to git..." -ForegroundColor Blue
git add .

# Show what will be committed
Write-Host "`n📝 Files to be committed:" -ForegroundColor Blue
git status --cached --short

# Commit the changes
Write-Host "`nCommitting changes..." -ForegroundColor Blue
git commit -m "ci(render): Add Render deployment configuration

- Add PostgreSQL dependency to pom.xml
- Create application-render.properties for Render environment
- Update CORS configuration for Render domains  
- Add Render build and start scripts
- Create render.yaml for Infrastructure as Code
- Update frontend API URL handling for production
- Add comprehensive deployment documentation and verification tools"

# Check if remote origin exists
$remoteCheck = git remote -v 2>$null
if ($LASTEXITCODE -eq 0 -and $remoteCheck) {
    Write-Host "`n✅ Remote origin found:" -ForegroundColor Green
    git remote -v
    
    # Push to main branch
    Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Blue
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host "🌐 Your repository is now updated with Render deployment configuration" -ForegroundColor Green
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host "1. Go to https://dashboard.render.com" -ForegroundColor White
        Write-Host "2. Follow the steps in RENDER_DEPLOYMENT.md" -ForegroundColor White
        Write-Host "3. Or use the render.yaml for one-click deployment" -ForegroundColor White
        
        # Show repository URL if available
        $repoUrl = git config --get remote.origin.url
        if ($repoUrl) {
            Write-Host "`n📍 Repository URL: $repoUrl" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "`n❌ Failed to push to GitHub!" -ForegroundColor Red
        Write-Host "Please check your credentials and try again" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n❌ No remote origin configured!" -ForegroundColor Red
    Write-Host "Please add your GitHub repository as remote origin:" -ForegroundColor Yellow
    Write-Host "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor White
    Write-Host "Then run this script again" -ForegroundColor White
}

Write-Host "`n🏁 Git operations complete!" -ForegroundColor Cyan