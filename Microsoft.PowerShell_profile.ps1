# =============================================================================
# PowerConfig - The Ultimate PowerShell Experience
# Entry Point: Microsoft.PowerShell_profile.ps1
# Inspired by thepinak503/dotfiles & ChrisTitusTech
# =============================================================================

$env:POWERCONFIG_DIR = $PSScriptRoot
$env:POWERSHELL_TELEMETRY_OPTOUT = "true"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Test-CommandExists { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

# -----------------------------------------------------------------------------
# ADMIN CHECK & PROMPT
# -----------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function global:prompt {
    $lastCode = $LASTEXITCODE
    if ($lastCode -ne 0 -and $lastCode -ne $null) { Write-Host " [EXIT:$lastCode]" -ForegroundColor Red }
    if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
}

# Starship
$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) { $env:Path = "$starshipBin;$env:Path" }

# -----------------------------------------------------------------------------
# ERROR LOGGING
# -----------------------------------------------------------------------------
$env:DOTFILES_STATE_DIR = "$env:USERPROFILE\.config\powerconfig-state"
if (-not (Test-Path $env:DOTFILES_STATE_DIR)) {
    New-Item -ItemType Directory -Path $env:DOTFILES_STATE_DIR -Force | Out-Null
}

# -----------------------------------------------------------------------------
# SOURCE ALL (auto-load from src/)
# -----------------------------------------------------------------------------
$SRC_DIR = Join-Path $env:POWERCONFIG_DIR "src"
$SourceFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.ps1" | Sort-Object Name

foreach ($file in $SourceFiles) {
    if (Test-Path $file.FullName) {
        . $file.FullName
    }
}

# -----------------------------------------------------------------------------
# MODE SYSTEM
# -----------------------------------------------------------------------------
function global:Set-PowerConfigMode {
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
    Write-Host "Restart PowerShell or run 'reload-profile'" -ForegroundColor Cyan
}
Set-Alias -Name chmode -Value Set-PowerConfigMode

$stateFile = "$env:USERPROFILE\.config\powerconfig-mode"
if (Test-Path $stateFile) { $env:POWERCONFIG_MODE = Get-Content $stateFile -First 1 }
else { $env:POWERCONFIG_MODE = "standard" }

# -----------------------------------------------------------------------------
# EDITOR CONFIG
# -----------------------------------------------------------------------------
$EDITOR = if (Test-CommandExists nvim) { "nvim" }
elseif (Test-CommandExists code) { "code --wait" }
else { "notepad" }

function global:Edit-Profile { & $EDITOR $PROFILE }
function global:Invoke-Profile { & $PROFILE }
function global:reload-profile { & $PROFILE }

# -----------------------------------------------------------------------------
# UPDATE
# -----------------------------------------------------------------------------
function global:Update-PowerConfig {
    Write-Host "Checking for updates..." -ForegroundColor Cyan
    if (Test-Path "$env:POWERCONFIG_DIR\.git") {
        git -C $env:POWERCONFIG_DIR pull
        Write-Host "Updated! Restart shell." -ForegroundColor Green
    } else {
        Write-Host "irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install/install.ps1 | iex" -ForegroundColor Yellow
    }
}

# -----------------------------------------------------------------------------
# LOCAL EXTENSIONS
# -----------------------------------------------------------------------------
$LOCAL_PROFILE = Join-Path $env:POWERCONFIG_DIR "profile.local.ps1"
if (Test-Path $LOCAL_PROFILE) { . $LOCAL_PROFILE }

# -----------------------------------------------------------------------------
# STARTUP - run fastfetch once
# -----------------------------------------------------------------------------
if (Test-CommandExists fastfetch -and -not $env:POWERCONFIG_FASTFETCH_RUN) {
    $env:POWERCONFIG_FASTFETCH_RUN = "1"
    fastfetch
}

# Window title
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerConfig | PowerShell $($PSVersionTable.PSVersion)$adminSuffix"

Write-Host "Use 'Show-Help' for help" -ForegroundColor Yellow