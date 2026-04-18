# =============================================================================
# PowerConfig - The Ultimate PowerShell Experience
# Entry Point: Microsoft.PowerShell_profile.ps1
# Inspired by Chris Titus Tech & thepinak503/dotfiles
# =============================================================================

# Opt-out of telemetry
$env:POWERSHELL_TELEMETRY_OPTOUT = "true"

# -----------------------------------------------------------------------------
# ERROR LOGGING (like thepinak503/dotfiles)
# -----------------------------------------------------------------------------
$env:DOTFILES_STATE_DIR = "$env:USERPROFILE\.config\powerconfig-state"
if (-not (Test-Path $env:DOTFILES_STATE_DIR)) {
    New-Item -ItemType Directory -Path $env:DOTFILES_STATE_DIR -Force | Out-Null
}

function global:prompt {
    $lastCode = $LASTEXITCODE
    if ($lastCode -ne 0 -and $lastCode -ne $null) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $cmd = $history.Count
        "$timestamp EXIT=$lastCode CMD=$cmd" | Out-File -Append -FilePath "$env:DOTFILES_STATE_DIR\errors.log"
    }
}

# Add starship to PATH if installed
$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) {
    $env:Path = "$starshipBin;$env:Path"
}

# Define Root Directory
$env:POWERCONFIG_DIR = $PSScriptRoot

# -----------------------------------------------------------------------------
# SOURCE-ALL LOGIC (Bash-style)
$SRC_DIR = Join-Path $env:POWERCONFIG_DIR "src"
$SourceFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.ps1" | Sort-Object Name

foreach ($file in $SourceFiles) {
    if (Test-Path $file.FullName) {
        . $file.FullName
    }
}

# -----------------------------------------------------------------------------
# MODE SYSTEM (like thepinak503/dotfiles)
# -----------------------------------------------------------------------------
function Set-PowerConfigMode {
    param(
        [ValidateSet("minimal", "standard", "supreme", "ultra-nerd")]
        [string]$Mode = "standard"
    )
    $env:POWERCONFIG_MODE = $Mode
    $stateFile = "$env:USERPROFILE\.config\powerconfig-mode"
    $stateDir = Split-Path $stateFile -Parent
    if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
    Set-Content -Path $stateFile -Value $Mode
    Write-Host "[OK] Mode set to: $Mode" -ForegroundColor Green
    Write-Host "Restart PowerShell or run 'reload' to apply" -ForegroundColor Cyan
}
Set-Alias -Name chmode -Value Set-PowerConfigMode

$stateFile = "$env:USERPROFILE\.config\powerconfig-mode"
if (Test-Path $stateFile) {
    $env:POWERCONFIG_MODE = Get-Content $stateFile -First 1
} else {
    $env:POWERCONFIG_MODE = "standard"
}
}

# -----------------------------------------------------------------------------
# DOCS HELPER
# -----------------------------------------------------------------------------
function Show-PowerDocs {
    $DocsPath = Join-Path $env:POWERCONFIG_DIR "docs/index.html"
    Start-Process $DocsPath
}

# -----------------------------------------------------------------------------
# LOCAL EXTENSIONS
# -----------------------------------------------------------------------------
$LOCAL_PROFILE = Join-Path $env:POWERCONFIG_DIR "profile.local.ps1"
if (Test-Path $LOCAL_PROFILE) {
    . $LOCAL_PROFILE
}

# -----------------------------------------------------------------------------
# STARTUP
# -----------------------------------------------------------------------------
if (Get-Command fastfetch -ErrorAction SilentlyContinue) { 
    if (-not $env:POWERCONFIG_FASTFETCH_RUN) {
        $env:POWERCONFIG_FASTFETCH_RUN = "1"
        fastfetch 
    }
}
