# =============================================================================
# PowerConfig Universal Installer
# Run: iwr https://is.gd/powerconfig | iex
# =============================================================================

$ErrorActionPreference = 'Stop'

$pcDir = "$env:USERPROFILE\.powerconfig"
$profilePath = "$pcDir\Microsoft.PowerShell_profile.ps1"

Write-Host "Installing PowerConfig..." -ForegroundColor Cyan

if (Test-Path $pcDir) {
    Write-Host "Updating existing installation..." -ForegroundColor Yellow
    Set-Location $pcDir
    git pull origin main 2>$null
} else {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    git clone https://github.com/thepinak503/powerconfig.git $pcDir
}

Write-Host "Setting up profile..." -ForegroundColor Cyan

$profileDir = "$env:USERPROFILE\Documents\WindowsPowerShell"
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$destProfile = "$profileDir\profile.ps1"
if (-not (Test-Path $destProfile)) {
    @"
. `"$env:USERPROFILE\.powerconfig\Microsoft.PowerShell_profile.ps1`
"@ | Out-File -FilePath $destProfile -Encoding UTF8
    Write-Host "Profile created at: $destProfile" -ForegroundColor Green
} else {
    Write-Host "Profile already exists. Backup and reinstall manually." -ForegroundColor Yellow
}

Write-Host "Installation complete! Restart PowerShell." -ForegroundColor Green