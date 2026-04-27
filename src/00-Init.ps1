# PowerConfig Init - Optimization, Detection & Maintenance
# Inspired by thepinak503/dotfiles

$env:POWERCONFIG_DIR = $PSScriptRoot | Split-Path -Parent
$env:DOTFILES_OS = $PSVersionTable.OS
$env:POWERCONFIG_ARCH = $env:PROCESSOR_ARCHITECTURE

function _detect_windows_distro {
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "windows-x64" }
    elseif ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "windows-arm64" }
    else { "windows-unknown" }
}
$env:DOTFILES_DISTRO = $(_detect_windows_distro)
$env:DOTFILES_PKG_MANAGER = "winget"

if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6 -and $env:OS -match "Windows")) {
    $env:DOTFILES_INIT = "windows"
} else {
    $env:DOTFILES_INIT = "unknown"
}

$env:POWERSHELL_TELEMETRY_OPTOUT = "true"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function global:Update-PowerConfig {
    Write-Host "Checking for PowerConfig updates..." -ForegroundColor Cyan
    if (Test-Path "$env:POWERCONFIG_DIR\.git") {
        git -C $env:POWERCONFIG_DIR pull origin main
        Write-Host "Update complete. Restart your shell." -ForegroundColor Green
    } else {
        Write-Host "Not a git repo. Reinstall with:" -ForegroundColor Yellow
        Write-Host "irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install/install.ps1 | iex" -ForegroundColor Cyan
    }
}

function global:Clear-Cache {
    Write-Host "Clearing User and System Temp..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cache cleared!" -ForegroundColor Green
}

function global:dottools {
    $tools = @("git", "curl", "tar", "docker", "nvim", "starship", "fastfetch", "kubectl", "terraform")
    Write-Host "`n=== PowerConfig Tool Status ===" -ForegroundColor Cyan
    foreach ($tool in $tools) {
        $exists = Get-Command $tool -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "[OK] $tool" -ForegroundColor Green
        } else {
            Write-Host "[--] $tool" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

function global:dotphase {
    Write-Host "`n=== Active Feature Phases ===" -ForegroundColor Cyan
    $phases = @{
        "starship" = "Prompt"
        "zoxide" = "SmartCD"
        "fastfetch" = "SysInfo"
        "docker" = "Containers"
        "kubectl" = "Kubernetes"
    }
    foreach ($phase in $phases.Keys) {
        $exists = Get-Command $phase -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "[*] $($phases[$phase]) - ACTIVE" -ForegroundColor Green
        } else {
            Write-Host "[ ] $($phases[$phase]) - Install $phase" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}