# =============================================================================
# PowerConfig Universal Installer
# Windows Only - ChrisTitusTech Style
# =============================================================================

$ErrorActionPreference = "Continue"

if (-not $IsWindows) {
    Write-Host "This installer is for Windows only." -ForegroundColor Yellow
    Write-Host "For Linux/Mac: https://github.com/thepinak503/dotfiles" -ForegroundColor Cyan
    exit 0
}

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$ProgressPreference = "SilentlyContinue"

function Get-ProfileDir {
    param([string]$Edition)
    if ($Edition -eq "Core") {
        return "$env:userprofile\Documents\PowerShell"
    } elseif ($Edition -eq "Desktop") {
        return "$env:userprofile\Documents\WindowsPowerShell"
    }
    return "$env:userprofile\Documents\PowerShell"
}

function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    } catch { return $false }
}

function Install-NerdFonts {
    param(
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )

    try {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        if ($fontFamilies -notcontains $FontDisplayName) {
            $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            $zipFilePath = "$env:TEMP\${FontName}.zip"
            $extractPath = "$env:TEMP\${FontName}"

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($fontZipUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            }

            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
                if (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                    $destination.CopyHere($_.FullName, 0x10)
                }
            }

            Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
            Write-Host "[OK] $FontDisplayName installed" -ForegroundColor Green
        } else {
            Write-Host "[SKIP] $FontDisplayName already installed" -ForegroundColor Gray
        }
    } catch {
        Write-Host "[ERROR] Font install failed: $_" -ForegroundColor Red
    }
}

function Set-WindowsTerminalFont {
    param([string]$FontFace = "CaskaydiaCove NF")

    $wtSettingsPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:APPDATA\Microsoft\WindowsTerminal\settings.json"
    )

    $settingsFile = $wtSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $settingsFile) { return $false }

    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $fontConfig = @{face = $FontFace; size = 12}

        if ($settings.defaults) {
            $settings.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontConfig -Force -ErrorAction SilentlyContinue
        } else {
            $settings | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{font = $fontConfig} -Force -ErrorAction SilentlyContinue
        }

        $updatedSettings = $settings | ConvertTo-Json -Depth 10
        Set-Content -Path $settingsFile -Value $updatedSettings -Encoding UTF8
        Write-Host "[OK] Windows Terminal font set to $FontFace" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[WARN] Could not set WT font: $_" -ForegroundColor Yellow
        return $false
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       POWERCONFIG UNIVERSAL INSTALLER v4.3                   ║" -ForegroundColor Cyan
Write-Host "║           ChrisTitusTech Style                 ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-InternetConnection)) {
    Write-Host "[ERROR] Internet connection required!" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] PowerConfig Installer" -ForegroundColor Cyan
Write-Host "Downloading profile from GitHub..." -ForegroundColor Yellow

$profileDir = Get-ProfileDir
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType "directory" -Force | Out-Null
}

$rawProfileUrl = "https://github.com/thepinak503/powerconfig/raw/main/Microsoft.PowerShell_profile.ps1"

$editions = @("Desktop", "Core")

foreach ($edition in $editions) {
    $profilePath = Get-ProfileDir -Edition $edition
    if (-not (Test-Path $profilePath)) {
        New-Item -Path $profilePath -ItemType "directory" -Force | Out-Null
    }

    $targetProfile = Join-Path $profilePath "profile.ps1"
    $hostSpecific = Join-Path $profilePath "Microsoft.PowerShell_profile.ps1"

    if ($edition -eq "Desktop") {
        $psPath = "C:\Windows\System32\WindowsPowerShell\v1.0"
        if (Test-Path $psPath) {
            $targetProfile = Join-Path $psPath "profile.ps1"
            $hostSpecific = Join-Path $psPath "Microsoft.PowerShell_profile.ps1"
        }
    } elseif ($edition -eq "Core") {
        $psPath = "$env:ProgramFiles\PowerShell\7"
        if (Test-Path $psPath) {
            $targetProfile = Join-Path $psPath "profile.ps1"
            $hostSpecific = Join-Path $psPath "Microsoft.PowerShell_profile.ps1"
        }
    }

    try {
        if (Test-Path $targetProfile) {
            Move-Item -Path $targetProfile -Destination "$targetProfile.bak" -Force
        }

        Invoke-RestMethod -Uri $rawProfileUrl -OutFile $targetProfile
        if ($targetProfile -ne $hostSpecific) {
            Invoke-RestMethod -Uri $rawProfileUrl -OutFile $hostSpecific
        }
        Write-Host "[OK] Profile installed for $edition" -ForegroundColor Green
    } catch {
        Write-Host "[WARN] Failed for $edition : $_" -ForegroundColor Yellow
    }
}

$PROFILE = if ($PSVersionTable.PSEdition -eq "Core") {
    "$env:userprofile\Documents\PowerShell\profile.ps1"
} else {
    "$env:userprofile\Documents\WindowsPowerShell\profile.ps1"
}

Write-Host ""
Write-Host "[INFO] Installing dependencies..." -ForegroundColor Cyan

try {
    Write-Host "  Installing Git..." -ForegroundColor Yellow
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
} catch {}

try {
    Write-Host "  Installing starship..." -ForegroundColor Yellow
    winget install -e --id Starship.Starship --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
} catch {}

try {
    Write-Host "  Installing zoxide..." -ForegroundColor Yellow
    winget install -e --id ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
} catch {}

try {
    Write-Host "  Installing Terminal-Icons module..." -ForegroundColor Yellow
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force 2>&1 | Out-Null
} catch {}

Write-Host ""
Write-Host "[INFO] Installing fonts..." -ForegroundColor Cyan
Install-NerdFonts -FontName "CascadiaCode" -FontDisplayName "CaskaydiaCove NF"
Set-WindowsTerminalFont -FontFace "CaskaydiaCove NF"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "[SUCCESS] Installation Complete!" -ForegroundColor Green
Write-Host "═════���═════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
Write-Host ""