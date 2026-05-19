param([string]$PreferredManager)
$ErrorActionPreference = "Stop"

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Relaunching as admin..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "PowerConfig Bootstrap" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop install git
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install git -y
    }
}

$repoUrl = "https://github.com/thepinak503/powerconfig"
$installDir = "$env:USERPROFILE\Documents\PowerConfig"

if (Test-Path $installDir) {
    git -C $installDir pull
} else {
    git clone $repoUrl $installDir
}

Write-Host "Bootstrap complete! Run install.ps1 in $installDir" -ForegroundColor Green
