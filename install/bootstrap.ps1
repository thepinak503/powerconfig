# PowerConfig Bootstrap
# Auto-installs package manager if needed, then installs PowerConfig

param(
    [ValidateSet("winget", "scoop", "choco")]
    [string]$PreferredManager = $null
)

$ErrorActionPreference = "Stop"

# Ensure TLS 1.2 for all remote calls (required for modern TLS endpoints)
if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

# Elevation: ensure the bootstrap runs elevated on Windows
if ($IsWindows) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "Relaunching with elevated privileges..." -ForegroundColor Yellow
        Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
}

$Red = "`e[0;31m"
$Green = "`e[0;32m"
$Yellow = "`e[1;33m"
$Blue = "`e[0;34m"
$Cyan = "`e[0;36m"
$Reset = "`e[0m"

function Write-Step($Message) { Write-Host "${Cyan}→${Reset} $Message" }
function Write-Success($Message) { Write-Host "${Green}✓${Reset} $Message" }
function Write-Error($Message) { Write-Host "${Red}✗${Reset} $Message" }
function Write-Info($Message) { Write-Host "  $Message" }

function Test-Command($Cmd) {
    Get-Command $Cmd -ErrorAction SilentlyContinue
}

function Get-InstalledPackageManagers() {
    $managers = @{}
    if (Get-Command "winget" -ErrorAction SilentlyContinue) { $managers["winget"] = $true }
    if (Get-Command "scoop" -ErrorAction SilentlyContinue) { $managers["scoop"] = $true }
    if (Get-Command "choco" -ErrorAction SilentlyContinue) { $managers["choco"] = $true }
    return $managers
}

function Install-Winget() {
    # Winget automation is out of scope for this bootstrap version.
    # If Winget is not available, inform the user and exit gracefully.
    Write-Step "Winget installation is not automated by this bootstrap in this version."
    Write-Info "Please install App Installer from the Microsoft Store or use an alternative package manager (scoop or chocolatey)."
    return $false
}

function Install-Scoop() {
    Write-Step "Installing Scoop..."
    
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri https://get.scoop.sh -UseBasicParsing | Invoke-Expression
        Write-Success "Scoop installed"
        return $true
    } catch {
        Write-Info "Failed: $_"
        return $false
    }
}

function Install-Chocolatey() {
    Write-Step "Installing Chocolatey..."
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $installScript = Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -UseBasicParsing
        Invoke-Expression $installScript.Content
        Write-Success "Chocolatey installed"
        return $true
    } catch {
        Write-Info "Failed: $_"
        return $false
    }
}

function Install-PackageManager($Manager) {
    switch ($Manager) {
        "winget" { return Install-Winget }
        "scoop" { return Install-Scoop }
        "choco" { return Install-Chocolatey }
    }
    return $false
}

function Install-Git($Manager) {
    Write-Step "Installing Git using $Manager..."
    
    switch ($Manager) {
        "winget" {
            winget install --id Git.Git --source winget --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) { Write-Success "Git installed via Winget"; return $true }
        }
        "scoop" {
            scoop install git
            if ($LASTEXITCODE -eq 0) { Write-Success "Git installed via Scoop"; return $true }
        }
        "choco" {
            choco install git -y
            if ($LASTEXITCODE -eq 0) { Write-Success "Git installed via Chocolatey"; return $true }
        }
    }
    return $false
}

function Install-GitIfNeeded($Manager) {
    if (Test-Command "git") {
        Write-Info "Git already installed"
        return $true
    }
    
    if (-not $Manager) {
        Write-Error "No package manager available to install Git"
        Write-Info "Please install one of: winget, scoop, or chocolatey"
        return $false
    }
    
    return Install-Git $Manager
}

function Select-PackageManager($Available, $Preferred) {
    if ($Preferred -and $Available[$Preferred]) {
        return $Preferred
    }
    
    $priority = @("winget", "scoop", "choco")
    foreach ($mgr in $priority) {
        if ($Available[$mgr]) {
            return $mgr
        }
    }
    return $null
}

function Get-PowerConfigRepo() {
    $repoUrl = "https://github.com/thepinak503/powerconfig"
    $installDir = "$env:USERPROFILE\.powerconfig"
    
    if (Test-Path $installDir) {
        Write-Step "PowerConfig directory exists, pulling latest..."
        Set-Location $installDir
        git pull
    } else {
        Write-Step "Cloning PowerConfig..."
        git clone $repoUrl $installDir
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "PowerConfig ready at $installDir"
        return $installDir
    }
    
    Write-Error "Failed to get PowerConfig"
    return $null
}

function Install-PowerConfig($InstallDir) {
    Write-Step "Running PowerConfig installer..."
    Set-Location $InstallDir
    & ".\install.ps1" -Mode advanced
}

# Main
Write-Host @"
${Cyan}
╔════════════════════════════════════════════════════════════╗
║           PowerConfig Bootstrap v1.0                      ║
║    Auto-install Git + PowerConfig on Windows              ║
╚════════════════════════════════════════════════════════════╝
${Reset}
"@

Write-Step "Checking environment..."
$available = Get-InstalledPackageManagers
Write-Info "Available: $(($available.Keys | ForEach-Object { $_ }) -join ', ' | ForEach-Object { if ($_) { $_ } else { 'none' } })"

if ($available.Count -eq 0) {
    Write-Step "No package managers found. Installing package manager..."
    
    if ($PreferredManager) {
        $installed = Install-PackageManager $PreferredManager
        if ($installed) {
            $available[$PreferredManager] = $true
            Write-Success "Installed $PreferredManager"
        }
    }
    
    if ($available.Count -eq 0) {
        $attempted = $false
        foreach ($mgr in @("winget", "scoop", "choco")) {
            if (-not $available[$mgr]) {
                Write-Info "Trying to install $mgr..."
                if (Install-PackageManager $mgr) {
                    $available[$mgr] = $true
                    Write-Success "Successfully installed $mgr"
                    break
                }
            }
        }
    }
}

$manager = Select-PackageManager $available $PreferredManager
if (-not $manager) {
    Write-Error "Could not find or install any package manager"
    exit 1
}

Write-Success "Using package manager: $manager"

if (-not (Install-GitIfNeeded $manager)) {
    Write-Error "Could not install Git"
    exit 1
}

$installDir = Get-PowerConfigRepo
if (-not $installDir) {
    Write-Error "Could not get PowerConfig repository"
    exit 1
}

Install-PowerConfig $installDir

Write-Host @"
${Green}
╔════════════════════════════════════════════════════════════╗
║           Installation Complete!                          ║
║    Restart PowerShell to use PowerConfig                   ║
╚════════════════════════════════════════════════════════════╝
${Reset}
"@
