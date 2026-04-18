# =============================================================================
# PowerConfig Universal Installer v5.0
# Uses $PROFILE variable for correct paths
# =============================================================================

$ErrorActionPreference = "Continue"

if (-not $IsWindows) {
    Write-Host "This installer is for Windows only." -ForegroundColor Yellow
    exit 0
}

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$ProgressPreference = "SilentlyContinue"
$RepoUrl = "https://github.com/thepinak503/powerconfig"
$InstallDir = "$env:USERPROFILE\Documents\Git\powerconfig"

function Test-InternetConnection {
    try { Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null; return $true } catch { return $false }
}

function Install-Font {
    param($FontName = "CascadiaCode", $FontDisplayName = "CaskaydiaCove NF", $Version = "3.2.1")
    try {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -notcontains $FontDisplayName) {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri("https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip")), "$env:TEMP\${FontName}.zip")
            while ($webClient.IsBusy) { Start-Sleep -Seconds 2 }
            Expand-Archive -Path "$env:TEMP\${FontName}.zip" -DestinationPath "$env:TEMP\${FontName}" -Force
            $dest = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path "$env:TEMP\${FontName}" -Recurse -Filter "*.ttf" | ForEach-Object {
                if (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) { $dest.CopyHere($_.FullName, 0x10) }
            }
            Remove-Item -Path "$env:TEMP\${FontName}*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] $FontDisplayName installed" -ForegroundColor Green
        } else {
            Write-Host "[SKIP] $FontDisplayName already installed" -ForegroundColor Gray
        }
    } catch { Write-Host "[WARN] Font: $_" -ForegroundColor Yellow }
}

function Set-WindowsTerminalFont {
    param($FontFace = "CaskaydiaCove NF")
    $settingsFile = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsFile) {
        try {
            $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
            $fontObj = @{face = $FontFace; size = 12}
            if ($settings.defaults) { $settings.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontObj -Force -ErrorAction SilentlyContinue }
            else { $settings | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{font = $fontObj} -Force -ErrorAction SilentlyContinue }
            Set-Content -Path $settingsFile -Value ($settings | ConvertTo-Json -Depth 10) -Encoding UTF8
            Write-Host "[OK] Windows Terminal font set" -ForegroundColor Green
        } catch { }
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       POWERCONFIG INSTALLER v5.0                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-InternetConnection)) {
    Write-Host "[ERROR] Internet required!" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Cloning PowerConfig..." -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    $gitDir = Split-Path $InstallDir
    if (-not (Test-Path $gitDir)) { New-Item -Path $gitDir -ItemType Directory -Force | Out-Null }
    git clone --depth=1 $RepoUrl $InstallDir 2>&1 | Out-Null
}

if (-not (Test-Path $InstallDir)) {
    Write-Host "[ERROR] Clone failed!" -ForegroundColor Red
    Write-Host "Please install Git first: winget install Git.Git" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Cloned to $InstallDir" -ForegroundColor Green

Write-Host ""
Write-Host "[INFO] Installing profiles..." -ForegroundColor Cyan

$escapedDir = $InstallDir -replace '\\', '\\'

$profileContent = @"
# PowerConfig Profile v5.0
`$env:POWERCONFIG_DIR = "$escapedDir"
`$env:STARSHIP_CONFIG = Join-Path (`$env:USERPROFILE) ".config\starship.toml"

`$mainProfile = Join-Path (`$env:POWERCONFIG_DIR) "Microsoft.PowerShell_profile.ps1"
if (Test-Path `$mainProfile) {
    . `$mainProfile
}
"@

function Install-ProfileForShell {
    param([string]$ShellType)
    
    if ($ShellType -eq "Desktop") {
        $basePath = "$env:USERPROFILE\Documents\WindowsPowerShell"
    } else {
        $basePath = "$env:USERPROFILE\Documents\PowerShell"
    }
    
    if (-not (Test-Path $basePath)) {
        New-Item -Path $basePath -ItemType Directory -Force | Out-Null
    }
    
    $allHostsProfile = Join-Path $basePath "profile.ps1"
    $currentHostProfile = Join-Path $basePath "Microsoft.PowerShell_profile.ps1"
    
    Set-Content -Path $allHostsProfile -Value $profileContent -Encoding UTF8
    Set-Content -Path $currentHostProfile -Value $profileContent -Encoding UTF8
    
    Write-Host "  [OK] $ShellType profiles installed" -ForegroundColor Green
}

Install-ProfileForShell -ShellType "Desktop"
Install-ProfileForShell -ShellType "Core"

$configDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }

$starshipSource = Join-Path $InstallDir "apps\starship\starship.toml"
if (Test-Path $starshipSource) {
    Copy-Item -Path $starshipSource -Destination "$configDir\starship.toml" -Force
    Write-Host "[OK] Starship config" -ForegroundColor Green
}

Write-Host ""
Write-Host "[INFO] Installing dependencies..." -ForegroundColor Cyan

function Install-IfNeeded {
    param([string]$Name, [string]$WingetId)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        try { winget install -e --id $WingetId --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null } catch { }
    }
}

Install-IfNeeded -Name "git" -WingetId "Git.Git"
Install-IfNeeded -Name "starship" -WingetId "Starship.Starship"
Install-IfNeeded -Name "zoxide" -WingetId "ajeetdsouza.zoxide"

try { Install-Module -Name Terminal-Icons -Repository PSGallery -Force 2>&1 | Out-Null } catch { }

Write-Host ""
Write-Host "[INFO] Installing fonts..." -ForegroundColor Cyan
Install-Font
Set-WindowsTerminalFont

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "[SUCCESS] Installation Complete!" -ForegroundColor Green
Write-Host "════════════════════════��══════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Restart PowerShell or: . `$PROFILE" -ForegroundColor Cyan
Write-Host ""