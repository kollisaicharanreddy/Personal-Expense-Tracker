# Simple Git Push Script
Write-Host "Pushing Personal Expense Tracker to GitHub for Render Deployment" -ForegroundColor Cyan

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "Not a git repository. Initializing..." -ForegroundColor Yellow
    git init
    Write-Host "Git repository initialized" -ForegroundColor Green
}

# Add all files
Write-Host "Adding all files to git..." -ForegroundColor Blue
git add .

# Commit the changes
Write-Host "Committing changes..." -ForegroundColor Blue
git commit -m "ci(render): Add Render deployment configuration"

# Check if remote origin exists
$remoteCheck = git remote -v 2>$null
if ($LASTEXITCODE -eq 0 -and $remoteCheck) {
    Write-Host "Remote origin found. Pushing to GitHub..." -ForegroundColor Blue
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Files pushed to GitHub!" -ForegroundColor Green
        Write-Host "Next: Go to https://dashboard.render.com" -ForegroundColor Yellow
    } else {
        Write-Host "FAILED: Could not push to GitHub" -ForegroundColor Red
    }
} else {
    Write-Host "No remote origin configured!" -ForegroundColor Red
    Write-Host "Add your GitHub repo: git remote add origin YOUR_GITHUB_URL" -ForegroundColor Yellow
}