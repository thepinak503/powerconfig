#!/usr/bin/env pwsh
# =============================================================================
# PowerConfig Universal Installer (One-Liner)
# Run: iwr https://is.gd/powerconfig | iex
# =============================================================================

[CmdletBinding()]param(
    [switch]$Force
)

$ErrorActionPreference = "Continue"

if (-not $IsWindows) {
    Write-Host "PowerConfig is Windows-only." -ForegroundColor Yellow
    exit 0
}

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$ProgressPreference = "SilentlyContinue"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       POWERCONFIG INSTALLER                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$RepoUrl = "https://github.com/thepinak503/powerconfig"
$InstallDir = "$env:USERPROFILE\Documents\Git\powerconfig"

function Test-InternetConnection {
    try { Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null; $true } catch { $false }
}

function Get-CurrentUser {
    [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Get-SafetyScore {
    param([string]$Url)
    $score = 50
    if ($Url -match "github\.com/thepinak503") { $score += 30 }
    if ($Url -match "raw\.git" -or $Url -match "gist\.github") { $score += 10 }
    $score
}

function Test-GitInstalled {
    $null -ne (Get-Command git -ErrorAction SilentlyContinue)
}

function Install-Git {
    Write-Host "Installing Git..." -ForegroundColor Cyan
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install git -y 2>&1 | Out-Null
        } else {
            $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"
            $gitPath = "$env:TEMP\Git-2.47.0.2-64-bit.exe"
            Invoke-WebRequest -Uri $gitUrl -OutFile $gitPath -UseBasicParsing
            Start-Process -FilePath $gitPath -ArgumentList "/VERYSILENT /NORESTART" -Wait
            Remove-Item $gitPath -Force
        }
    } catch { }
}

function Install-Font {
    param($FontName = "CascadiaCode", $FontDisplayName = "CaskaydiaCove NF", $Version = "3.2.1")
    try {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -notcontains $FontDisplayName) {
            $zip = "$env:TEMP\$FontName.zip"
            $dir = "$env:TEMP\$FontName"
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri("https://github.com/ryanoasis/nerd-fonts/releases/download/v$Version/$FontName.zip")), $zip)
            while ($webClient.IsBusy) { Start-Sleep -Seconds 2 }
            Expand-Archive -Path $zip -DestinationPath $dir -Force
            $dest = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path $dir -Recurse -Filter "*.ttf" | ForEach-Object {
                if (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) { $dest.CopyHere($_.FullName, 0x10) }
            }
            Remove-Item $dir, $zip -Recurse -Force -EA SilentlyContinue
            Write-Host "  [OK] $FontDisplayName" -ForegroundColor Green
        }
    } catch { }
}

function Set-TerminalFont {
    param($FontFace = "CaskaydiaCove NF")
    $settingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsFile) {
        try {
            $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
            $fontObj = @{face = $FontFace; size = 12}
            if ($settings.defaults) { $settings.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontObj -Force -EA SilentlyContinue }
            else { $settings | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{font = $fontObj} -Force -EA SilentlyContinue }
            Set-Content -Path $settingsFile -Value ($settings | ConvertTo-Json -Depth 10) -Encoding UTF8
            Write-Host "  [OK] Terminal font set" -ForegroundColor Green
        } catch { }
    }
}

function Install-Deps {
    param([string]$Name, [string]$Id)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing $Name..." -ForegroundColor Cyan
        try { winget install -e --id $Id --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null } catch { }
    }
}

Write-Host "User: $(Get-CurrentUser)" -ForegroundColor White
Write-Host ""

$safety = Get-SafetyScore -Url $RepoUrl
Write-Host "[CHECK] Safety Score: $safety/100" -ForegroundColor $(if ($safety -ge 70) { "Green" } else { "Yellow" })

if ($safety -lt 40) {
    Write-Host "[ERROR] Unsafe! Aborting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[CHECK] Git..." -ForegroundColor Cyan
if (-not (Test-GitInstalled)) {
    Install-Git
} else {
    Write-Host "  [OK] $(git --version)" -ForegroundColor Green
}

Write-Host ""
Write-Host "[CHECK] Internet..." -ForegroundColor Cyan
if (-not (Test-InternetConnection)) {
    Write-Host "[ERROR] No internet!" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Connected" -ForegroundColor Green

Write-Host ""
Write-Host "[CLONE] Cloning PowerConfig..." -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    $dir = Split-Path $InstallDir
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
    git clone --depth=1 $RepoUrl $InstallDir 2>&1 | Out-Null
}
if (-not (Test-Path $InstallDir)) {
    Write-Host "[ERROR] Clone failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] $InstallDir" -ForegroundColor Green

Write-Host ""
Write-Host "[INSTALL] Installing profiles..." -ForegroundColor Cyan

$profileContent = @'
# PowerConfig Profile
$env:POWERCONFIG_DIR = $PSScriptRoot
$env:STARSHIP_CONFIG = Join-Path ($env:USERPROFILE) ".config\starship.toml"

$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) {
    $env:Path = "$starshipBin;$env:Path"
}

$DOTFILES_DIR = "$env:USERPROFILE\.config\powerconfig-state"
if (-not (Test-Path $DOTFILES_DIR)) {
    New-Item -ItemType Directory -Path $DOTFILES_DIR -Force | Out-Null
}

$SRC_DIR = Join-Path $PSScriptRoot "src"
Get-ChildItem -Path $SRC_DIR -Filter "*.ps1" -EA SilentlyContinue | Sort-Object Name | ForEach-Object {
    . $_.FullName
}

$env:POWERCONFIG_MODE = "standard"
'@

@(
    @{Name="PowerShell 7+"; Dir="$env:USERPROFILE\Documents\PowerShell"},
    @{Name="PowerShell 5.1"; Dir="$env:USERPROFILE\Documents\WindowsPowerShell"}
) | ForEach-Object {
    $targetDir = $_.Dir
    Write-Host "  Installing to $($_.Name)..." -ForegroundColor Yellow
    if (-not (Test-Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force | Out-Null }
    
    $profilePath = Join-Path $targetDir "profile.ps1"
    $hostProfile = Join-Path $targetDir "Microsoft.PowerShell_profile.ps1"
    $srcDir = Join-Path $targetDir "src"
    
    $profilePath | New-Item -Path $profilePath -ItemType File -Force | Out-Null
    Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
    
    $hostProfile | New-Item -Path $hostProfile -ItemType File -Force | Out-Null
    Set-Content -Path $hostProfile -Value $profileContent -Encoding UTF8
    
    if (Test-Path $srcDir) { Remove-Item $srcDir -Recurse -Force }
    Copy-Item -Path (Join-Path $InstallDir "src") -Destination $srcDir -Recurse -Force
    
    Write-Host "    [OK] profile + src/" -ForegroundColor Green
}

$configDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }
$starshipSource = Join-Path $InstallDir "apps\starship\starship.toml"
if (Test-Path $starshipSource) {
    Copy-Item -Path $starshipSource -Destination "$configDir\starship.toml" -Force
}

Write-Host ""
Write-Host "[DEPS] Installing dependencies..." -ForegroundColor Cyan
Install-Deps -Name "starship" -Id "Starship.Starship"
Install-Deps -Name "zoxide" -Id "ajeetdsouza.zoxide"
try { 
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -EA SilentlyContinue
    }
} catch { }

Write-Host ""
Write-Host "[FONTS] Installing fonts..." -ForegroundColor Cyan
Install-Font
Set-TerminalFont

Write-Host ""
Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "[SUCCESS] Installation Complete!" -ForegroundColor Green
Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Restart PowerShell or: . `$PROFILE" -ForegroundColor Cyan
Write-Host ""