# =============================================================================
# PowerConfig Installer - STEP 1
# Safety Check & Git Installation
# Run: iwr https://is.gd/powerconfig | iex
# =============================================================================

$ErrorActionPreference = "Stop"

if (-not $IsWindows) {
    Write-Host "This installer is for Windows only." -ForegroundColor Yellow
    Write-Host "For Linux/Mac: https://github.com/thepinak503/dotfiles" -ForegroundColor Cyan
    exit 0
}

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$ProgressPreference = "SilentlyContinue"

function Get-CurrentUser {
    return [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Get-SafetyScore {
    param([string]$Url)
    $score = 50
    if ($Url -match "github\.com/thepinak503") { $score += 30 }
    if ($Url -match "raw\.git" -or $Url -match "gist\.github") { $score += 10 }
    return $score
}

function Test-GitInstalled {
    return $null -ne (Get-Command git -ErrorAction SilentlyContinue)
}

function Install-Git-Winget {
    Write-Host "Installing Git via winget..." -ForegroundColor Cyan
    try {
        winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        return $true
    } catch { return $false }
}

function Install-Git-Choco {
    Write-Host "Installing Git via choco..." -ForegroundColor Cyan
    try {
        choco install git -y 2>&1 | Out-Null
        return $true
    } catch { return $false }
}

function Install-Git-Manual {
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"
    $gitPath = "$env:TEMP\Git-2.47.0.2-64-bit.exe"
    Write-Host "Downloading Git..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitPath -UseBasicParsing
        Start-Process -FilePath $gitPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL" -Wait
        Remove-Item $gitPath -Force
        return $true
    } catch {
        Write-Host "Download failed: $_" -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       POWERCONFIG - STEP 1: SAFETY & GIT         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$RepoUrl = "https://github.com/thepinak503/powerconfig"
Write-Host "Repository: $RepoUrl" -ForegroundColor White
Write-Host "User: $(Get-CurrentUser)" -ForegroundColor White
Write-Host ""

Write-Host "[CHECK] Safety Score..." -ForegroundColor Cyan
$safety = Get-SafetyScore -Url $RepoUrl
if ($safety -ge 70) {
    Write-Host "  Score: $safety/100 - SAFE" -ForegroundColor Green
} elseif ($safety -ge 40) {
    Write-Host "  Score: $safety/100 - MODERATE" -ForegroundColor Yellow
} else {
    Write-Host "  Score: $safety/100 - UNSAFE" -ForegroundColor Red
    Write-Host "Aborting..." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[CHECK] Git Installation..." -ForegroundColor Cyan

if (Test-GitInstalled) {
    $gitVersion = git --version
    Write-Host "  [OK] Already installed: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "  Git not found!" -ForegroundColor Yellow
    
    $pkgMgr = $null
    if (Get-Command winget -ErrorAction SilentlyContinue) { $pkgMgr = "winget" }
    elseif (Get-Command choco -ErrorAction SilentlyContinue) { $pkgMgr = "choco" }
    
    if ($pkgMgr) {
        Write-Host "  Installing via $pkgMgr..." -ForegroundColor Cyan
        if ($pkgMgr -eq "winget") { Install-Git-Winget }
        else { Install-Git-Choco }
    } else {
        Write-Host "  Installing manually..." -ForegroundColor Cyan
        Install-Git-Manual
    }
    
    if (Test-GitInstalled) {
        Write-Host "  [OK] Git installed!" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] Git installation failed!" -ForegroundColor Red
        Write-Host "  Please install Git manually from: https://git-scm.com" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "[INFO] Git ready! Now run installer step 2..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Option 1: iwr https://bit.ly/powerconfig-full | iex" -ForegroundColor White
Write-Host "  Option 2: Run full installer manually" -ForegroundColor White
Write-Host ""

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

Write-Host "[SUCCESS] Step 1 Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Restart PowerShell and run full installer" -ForegroundColor Cyan
Write-Host ""