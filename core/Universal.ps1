$env:STARSHIP_CONFIG = Join-Path $env:POWERCONFIG_DIR "apps\starship\starship.toml"

$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) {
    $env:Path = "$starshipBin;$env:Path"
}

$global:EDITOR = if (Get-Command nvim -ErrorAction SilentlyContinue) { "nvim" }
    elseif (Get-Command code -ErrorAction SilentlyContinue) { "code --wait" }
    else { "notepad" }

$env:POWERSHELL_TELEMETRY_OPTOUT = "true"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$global:OLDPWD = $null

function global:Set-Location-Parent { Set-Location .. }
function global:Set-Location-UpTwo { Set-Location ../.. }
function global:Set-Location-Home { Set-Location ~ }

function global:Update-PowerConfig {
    Write-Host "Checking for PowerConfig updates..." -ForegroundColor Cyan
    if (Test-Path (Join-Path $env:POWERCONFIG_DIR ".git")) {
        git -C $env:POWERCONFIG_DIR pull origin main
        Write-Host "Update complete. Restart your shell." -ForegroundColor Green
    } else {
        Write-Host "Not a git repo. Reinstall with:" -ForegroundColor Yellow
        Write-Host "irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install/install.ps1 | iex" -ForegroundColor Cyan
    }
}

function global:Set-PowerConfigMode {
    param(
        [ValidateSet("minimal", "standard", "supreme", "ultra-nerd")]
        [string]$Mode = "standard"
    )
    $env:POWERCONFIG_MODE = $Mode
    $stateFile = "$env:LOCALAPPDATA\powerconfig-mode"
    $stateDir = Split-Path $stateFile -Parent
    if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
    Set-Content -Path $stateFile -Value $Mode
    Write-Host "[OK] Mode set to: $Mode" -ForegroundColor Green
    Write-Host "Restart PowerShell or run 'reload-profile'" -ForegroundColor Cyan
}

$stateFile = "$env:LOCALAPPDATA\powerconfig-mode"
if (Test-Path $stateFile) { $env:POWERCONFIG_MODE = Get-Content $stateFile -First 1 }
else { $env:POWERCONFIG_MODE = "standard" }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$Host.UI.RawUI.WindowTitle = "PowerConfig | PowerShell $($PSVersionTable.PSVersion)$(if($isAdmin){' [ADMIN]'})"

function global:prompt {
    $lastCode = $LASTEXITCODE
    if ($lastCode -ne 0 -and $null -ne $lastCode) { Write-Host " [EXIT:$lastCode]" -ForegroundColor Red }
    $prefix = if ($isAdmin) { "#" } else { "$" }
    "[$(Get-Location)] $prefix "
}

$env:POWERCONFIG_STATE_DIR = "$env:USERPROFILE\.config\powerconfig-state"
if (-not (Test-Path $env:POWERCONFIG_STATE_DIR)) {
    New-Item -ItemType Directory -Path $env:POWERCONFIG_STATE_DIR -Force | Out-Null
}
