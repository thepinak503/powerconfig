# PowerConfig Installer
# One-command setup for PowerShell configuration

param(
    [string]$Mode = "advanced",
    [switch]$Force
)

# Colors
$Red = "`e[0;31m"
$Green = "`e[0;32m"
$Yellow = "`e[1;33m"
$Blue = "`e[0;34m"
$Purple = "`e[0;35m"
$Cyan = "`e[0;36m"
$White = "`e[1;37m"
$Reset = "`e[0m"

# Configuration
$RepoUrl = "https://github.com/thepinak503/powerconfig"
$InstallDir = "$env:USERPROFILE\.powerconfig"
$BackupDir = "$env:USERPROFILE\.powerconfig-backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"

function Print-Header {
    Write-Host @"
${Cyan}${White}
╔════════════════════════════════════════════════════════════╗
║           POWERCONFIG INSTALLER v1.0.0                     ║
║    The Ultimate PowerShell Configuration                   ║
║    Windows Package Manager Support: Scoop, Chocolatey      ║
╚════════════════════════════════════════════════════════════╝
${Reset}
"@
}

function Print-Success($Message) {
    Write-Host "${Green}✓${Reset} $Message"
}

function Print-Error($Message) {
    Write-Host "${Red}✗${Reset} $Message"
}

function Print-Info($Message) {
    Write-Host "${Blue}ℹ${Reset} $Message"
}

function Print-Warning($Message) {
    Write-Host "${Yellow}⚠${Reset} $Message"
}

function Print-Step($Message) {
    Write-Host "${Purple}→${Reset} $Message"
}

function Check-Prerequisites {
    Print-Step "Checking prerequisites..."
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Print-Error "PowerShell 5.0 or higher required"
        exit 1
    }
    
    Print-Success "Prerequisites check passed"
}

function Detect-PackageManagers {
    Print-Step "Detecting package managers..."
    
    $managers = @()
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $managers += "Scoop"
        Print-Info "✓ Scoop detected"
    }
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $managers += "Chocolatey"
        Print-Info "✓ Chocolatey detected"
    }
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $managers += "Winget"
        Print-Info "✓ Winget detected"
    }
    
    if ($managers.Count -eq 0) {
        Print-Warning "No package managers found"
        Print-Info "Install Scoop: iwr -useb get.scoop.sh | iex"
        Print-Info "Or Chocolatey: https://chocolatey.org/install"
    } else {
        Print-Success "Found: $($managers -join ', ')"
    }
}

function Backup-Existing {
    Print-Step "Backing up existing PowerShell profile..."
    
    if (Test-Path $PROFILE) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Copy-Item -Path $PROFILE -Destination $BackupDir\
        Print-Info "Backed up profile to $BackupDir"
    }
    
    Print-Success "Backup completed"
}

function Install-PowerConfig {
    Print-Step "Installing PowerConfig..."
    
    # Clone or update
    if (Test-Path $InstallDir) {
        if (-not $Force) {
            Print-Warning "PowerConfig already exists. Use -Force to overwrite"
            return
        }
        Remove-Item -Path $InstallDir -Recurse -Force
    }
    
    # Clone repository
    git clone --depth=1 $RepoUrl $InstallDir
    
    if (-not $?) {
        Print-Error "Failed to clone repository"
        exit 1
    }
    
    Print-Success "PowerConfig installed to $InstallDir"
}

function Install-Dependencies {
    Print-Step "Installing dependencies..."
    
    $packages = @(
        "git",
        "fzf",
        "zoxide",
        "eza",
        "bat",
        "ripgrep",
        "fd",
        "delta",
        "starship"
    )
    
    # Try Scoop first
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Print-Info "Installing with Scoop..."
        foreach ($pkg in $packages) {
            scoop install $pkg 2>$null
            if ($?) {
                Print-Info "Installed: $pkg"
            }
        }
    }
    # Then Chocolatey
    elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Print-Info "Installing with Chocolatey..."
        foreach ($pkg in $packages) {
            choco install -y $pkg 2>$null
            if ($?) {
                Print-Info "Installed: $pkg"
            }
        }
    }
    # Then Winget
    elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Print-Info "Installing with Winget..."
        foreach ($pkg in $packages) {
            winget install --silent $pkg 2>$null
            if ($?) {
                Print-Info "Installed: $pkg"
            }
        }
    }
    else {
        Print-Warning "No package manager found. Install dependencies manually:"
        Print-Info $packages -join ", "
    }
    
    Print-Success "Dependencies installation completed"
}

function Create-Profile {
    Print-Step "Creating PowerShell profile..."
    
    # Ensure profile directory exists
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Create profile that sources PowerConfig
    $profileContent = @"
# PowerConfig Profile
`$env:POWERCONFIG_MODE = "$Mode"
`$env:POWERCONFIG_DIR = "$InstallDir"

# Source PowerConfig
. "$InstallDir\Microsoft.PowerShell_profile.ps1"
"@
    
    Set-Content -Path $PROFILE -Value $profileContent
    
    Print-Success "Profile created at $PROFILE"
}

function Main {
    Print-Header
    
    Check-Prerequisites
    Detect-PackageManagers
    
    Write-Host ""
    $confirm = Read-Host "Continue with installation? [Y/n]"
    if ($confirm -match "^[Nn]`$") {
        Print-Error "Installation cancelled"
        exit 0
    }
    
    Backup-Existing
    Install-PowerConfig
    Install-Dependencies
    Create-Profile
    
    Write-Host ""
    Print-Success "Installation completed successfully!"
    Write-Host ""
    Print-Info "Backup location: $BackupDir"
    Print-Info "Install location: $InstallDir"
    Write-Host ""
    Print-Step "To apply changes, restart PowerShell or run:"
    Write-Host "  ${White}. `$PROFILE${Reset}"
    Write-Host ""
    Write-Host "${Cyan}Happy hacking!${Reset}"
}

# Run installation
Main
