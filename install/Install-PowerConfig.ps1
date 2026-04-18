# =============================================================================
# PowerConfig Universal Installer v4.2
# Windows Only - Fully Automatic with Fonts
# =============================================================================

[CmdletBinding()]param(
    [switch]$AllUsers,
    [switch]$SkipDependencies,
    [switch]$SkipFonts,
    [switch]$Uninstall
)

if (-not $IsWindows) {
    Write-Host "This installer is for Windows only." -ForegroundColor Yellow
    Write-Host "For Linux/Mac: https://github.com/thepinak503/dotfiles" -ForegroundColor Cyan
    exit 0
}

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$InstallerVersion = "4.1.0"
$InstallSourceDir = "$env:USERPROFILE\Documents\Git\powerconfig"

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($AllUsers -and -not $IsAdmin) {
    Write-Host "Administrator required for AllUsers. Relaunching..." -ForegroundColor Yellow
    Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -AllUsers" -Verb RunAs
    exit
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Write-Msg {
    param([string]$Msg, [string]$Color = "White")
    Write-Host $Msg -ForegroundColor $Color
}

function Get-PackageManager {
    if (Test-CommandExists "winget") { return "winget" }
    if (Test-CommandExists "choco") { return "choco" }
    return $null
}

function Install-Chocolatey {
    if (Test-CommandExists "choco") { return $true }
    Write-Msg "Installing Chocolatey..." -Color Cyan
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.SecurityProtocolType]::Tls12
        Invoke-Expression ((Invoke-WebRequest -Uri "https://community.chocolatey.org/install.ps1" -UseBasicParsing).Content)
        if (Test-CommandExists "choco") { return $true }
    } catch {
        Write-Msg "Failed to install Chocolatey: $_" -Color Red
        return $false
    }
}

function Install-Package {
    param([string]$Manager, [string]$PackageId, [string]$ChocoName = $null)
    
    $name = if ($ChocoName -and $Manager -eq "choco") { $ChocoName } else { $PackageId }
    
    try {
        if ($Manager -eq "winget") {
            $result = winget install --id $PackageId --silent --accept-source-agreements --accept-package-agreements 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed|already exists|No newer package") { return $true }
        } elseif ($Manager -eq "choco") {
            $result = choco install $name -y --no-progress 2>&1
            if ($LASTEXITCODE -eq 0) { return $true }
        }
    } catch {}
    return $false
}

function Install-Program {
    param([string]$Name, [string]$WingetId, [string]$ChocoName = $null)
    
    if (Test-CommandExists $Name) {
        Write-Msg "  [SKIP] $Name already installed" -Color Gray
        return $true
    }
    
    $specialPaths = @{
        "starship" = "$env:ProgramFiles\starship\bin\starship.exe"
    }
    if ($specialPaths.ContainsKey($Name) -and (Test-Path $specialPaths[$Name])) {
        Write-Msg "  [SKIP] $Name already installed (manual PATH)" -Color Gray
        return $true
    }
    
    Write-Msg "  [INSTALL] $Name..." -Color Cyan
    
    $pkgMgr = Get-PackageManager
    if ($pkgMgr -eq "winget") {
        if (Install-Package -Manager "winget" -PackageId $WingetId) { return $true }
    }
    if ($pkgMgr -eq "choco") {
        if (Install-Package -Manager "choco" -PackageId $WingetId -ChocoName $ChocoName) { return $true }
    }
    
    Write-Msg "  [WARN] Could not install $Name" -Color Yellow
    return $false
}

function Install-Font {
    param(
        [string]$FontName = "CascadiaCode",
        [string]$FontDisplayName = "CaskaydiaCove NF",
        [string]$Version = "3.2.1"
    )
    
    try {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        
        if ($fontFamilies -contains $FontDisplayName) {
            Write-Msg "  [SKIP] $FontDisplayName already installed" -Color Gray
            Set-WindowsTerminalFont -FontFace $FontDisplayName
            return $true
        }
        
        Write-Msg "  [INSTALL] $FontDisplayName..." -Color Cyan
        
        $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
        $zipFilePath = "$env:TEMP\${FontName}.zip"
        $extractPath = "$env:TEMP\${FontName}"
        
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($fontZipUrl, $zipFilePath)
        
        Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
        
        $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
        Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
            if (-not (Test-Path "C:\Windows\Fonts\$($_.Name)")) {
                $destination.CopyHere($_.FullName, 0x10)
            }
        }
        
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $zipFilePath -Force -ErrorAction SilentlyContinue
        
        Write-Msg "  [OK] $FontDisplayName installed" -Color Green
        Set-WindowsTerminalFont -FontFace $FontDisplayName
        return $true
    } catch {
        Write-Msg "  [ERROR] Font install failed: $_" -Color Red
        return $false
    }
}

function Set-WindowsTerminalFont {
    param([string]$FontFace = "CaskaydiaCove NF")
    
    $wtSettingsPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:APPDATA\Microsoft\WindowsTerminal\settings.json"
    )
    
    $settingsFile = $wtSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $settingsFile) {
        Write-Msg "  [INFO] Windows Terminal settings not found" -Color Yellow
        return $false
    }
    
    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        
        $fontConfig = @{
            face = $FontFace
            size = 12
        }
        
        if ($settings.defaults) {
            $settings.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontConfig -Force -ErrorAction SilentlyContinue
        } else {
            $settings | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{font = $fontConfig} -Force -ErrorAction SilentlyContinue
        }
        
        if ($settings.schemes) {
            $schemeNames = $settings.schemes | ForEach-Object { $_.name }
            $defaultScheme = if ($settings.defaults.colorScheme) { $settings.defaults.colorScheme } else { "Campbell" }
        }
        
        $updatedSettings = $settings | ConvertTo-Json -Depth 10
        Set-Content -Path $settingsFile -Value $updatedSettings -Encoding UTF8
        
        Write-Msg "  [OK] Windows Terminal font set to $FontFace" -Color Green
        return $true
    } catch {
        Write-Msg "  [WARN] Could not set WT font: $_" -Color Yellow
        return $false
    }
}

function Install-TerminalIconsModule {
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Msg "  [SKIP] Terminal-Icons already installed" -Color Gray
        return $true
    }
    Write-Msg "  [INSTALL] Terminal-Icons..." -Color Cyan
    try {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop
        return $true
    } catch {
        Write-Msg "  [ERROR] Failed: $_" -Color Red
        return $false
    }
}

function Get-PowerShellEditions {
    $editions = @()
    try {
        if (Get-Command powershell -ErrorAction SilentlyContinue) { $editions += @{Name="WindowsPowerShell"} }
    } catch {}
    try {
        if (Get-Command pwsh -ErrorAction SilentlyContinue) { $editions += @{Name="PowerShell"} }
    } catch {}
    return $editions
}

function Get-ProfilePaths {
    param([string]$ShellName, [string]$Scope)
    
    $paths = @{}
    
    if ($ShellName -eq "WindowsPowerShell") {
        $psHomePath = if ($Scope -eq "AllUsers") { "C:\Windows\System32\WindowsPowerShell\v1.0" } else { $null }
        $docDir = "$env:USERPROFILE\Documents\WindowsPowerShell"
    } else {
        $psHomePath = $null
        if ($Scope -eq "AllUsers") {
            $psHomePath = $env:ProgramFiles
            if (Test-Path "$psHomePath\PowerShell\7") { $psHomePath = "$psHomePath\PowerShell\7" }
        }
        $docDir = "$env:USERPROFILE\Documents\PowerShell"
    }
    
    if ($Scope -eq "AllUsers" -and $psHomePath) {
        $paths.AllUsersAllHosts = Join-Path $psHomePath "profile.ps1"
        $paths.AllUsersCurrentHost = Join-Path $psHomePath "Microsoft.PowerShell_profile.ps1"
    }
    
    $paths.CurrentUserAllHosts = Join-Path $docDir "profile.ps1"
    $paths.CurrentUserCurrentHost = Join-Path $docDir "Microsoft.PowerShell_profile.ps1"
    
    return $paths
}

function Install-ProfileForShell {
    param([string]$ShellName, [string]$Scope)
    
    $paths = Get-ProfilePaths -ShellName $ShellName -Scope $Scope
    $escapedDir = $InstallSourceDir -replace '\\', '\\'
    
    $profileContent = @"
# PowerConfig Profile v$InstallerVersion
# Shell: $ShellName | Scope: $Scope

`$env:POWERCONFIG_DIR = "$escapedDir"

`$starshipPath = Join-Path (`$env:USERPROFILE) ".config\starship.toml"
`$env:STARSHIP_CONFIG = "`$starshipPath"

`$mainProfile = Join-Path (`$env:POWERCONFIG_DIR) "Microsoft.PowerShell_profile.ps1"
if (Test-Path `$mainProfile) {
    . `$mainProfile
}
"@
    
    $installed = 0
    foreach ($type in @("CurrentUserAllHosts", "CurrentUserCurrentHost")) {
        $path = $paths.$type
        if ($path) {
            $dir = Split-Path $path -Parent
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            if (Test-Path $path) { Copy-Item $path "$path.bak" -Force }
            Set-Content -Path $path -Value $profileContent -Encoding UTF8
            Write-Msg "  [OK] $path" -Color Green
            $installed++
        }
    }
    return $installed
}

function Test-InternetConnection {
    try {
        Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop | Out-Null
        return $true
    } catch { return $false }
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       POWERCONFIG UNIVERSAL INSTALLER v$InstallerVersion            ║" -ForegroundColor Cyan
    Write-Host "║           Fully Automatic Installation                   ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-InternetConnection)) {
        Write-Msg "Internet required!" -Color Red
        exit 1
    }
    
    $scope = if ($AllUsers) { "AllUsers" } else { "CurrentUser" }
    
    Write-Msg "Configuration:" -Color Cyan
    Write-Msg "  Scope:       $scope" -Color White
    Write-Msg "  Admin:      $IsAdmin" -Color White
    Write-Msg "  Source:     $InstallSourceDir" -Color White
    Write-Host ""
    
    if (-not (Test-Path $InstallSourceDir)) {
        Write-Msg "[ERROR] PowerConfig not found!" -Color Red
        Write-Msg "Clone first: git clone https://github.com/thepinak503/powerconfig `"$InstallSourceDir`"" -Color Yellow
        exit 1
    }
    
    $pkgMgr = Get-PackageManager
    if (-not $pkgMgr) {
        Write-Msg "No package manager. Installing Chocolatey..." -Color Yellow
        Install-Chocolatey
        $pkgMgr = Get-PackageManager
    }
    Write-Msg "Package Manager: $pkgMgr" -Color Cyan
    
    $configDir = "$env:USERPROFILE\.config"
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }
    
    $starshipConfigSource = Join-Path $InstallSourceDir "apps\starship\starship.toml"
    $starshipConfigTarget = Join-Path $configDir "starship.toml"
    if (Test-Path $starshipConfigSource) {
        Copy-Item $starshipConfigSource $starshipConfigTarget -Force
        Write-Msg "[OK] Starship config" -Color Green
    }
    
    if (-not $SkipFonts) {
        Write-Host ""
        Write-Msg "Installing fonts..." -Color Cyan
        Install-Font
    }
    
    if (-not $SkipDependencies) {
        Write-Host ""
        Write-Msg "Installing dependencies..." -Color Cyan
        Install-Program -Name "git" -WingetId "Git.Git" -ChocoName "git"
        Install-Program -Name "starship" -WingetId "Starship.Starship" -ChocoName "starship"
        Install-Program -Name "zoxide" -WingetId "ajeetdsouza.zoxide" -ChocoName "zoxide"
        Install-Program -Name "eza" -WingetId "eza-community.eza" -ChocoName "eza"
        Install-Program -Name "bat" -WingetId "sharkdp.bat" -ChocoName "bat"
        Install-Program -Name "ripgrep" -WingetId "BurntSushi.ripgrep.MSVC" -ChocoName "ripgrep"
        Install-Program -Name "fd" -WingetId "sharkdp.fd" -ChocoName "fd"
        Install-Program -Name "fastfetch" -WingetId "Fastfetch-cli.Fastfetch" -ChocoName "fastfetch"
        Install-TerminalIconsModule
    }
    
    Write-Host ""
    Write-Msg "Installing profiles..." -Color Cyan
    
    $shells = Get-PowerShellEditions
    if ($shells.Count -eq 0) { $shells = @(@{Name=if ($PSVersionTable.PSEdition -eq "Core") { "PowerShell" } else { "WindowsPowerShell" }}) }
    
    $totalInstalled = 0
    foreach ($shell in $shells) {
        Write-Msg "  Shell: $($shell.Name)" -Color Yellow
        $totalInstalled += Install-ProfileForShell -ShellName $shell.Name -Scope $scope
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "[SUCCESS] Installation Complete! ($totalInstalled profiles)" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Msg "Restart PowerShell or: . `$PROFILE" -Color Cyan
    Write-Host ""
    
    Write-Host ""
    Write-Host "[OK] Font and Windows Terminal configured automatically!" -ForegroundColor Green
    Write-Host "Restart Windows Terminal to apply changes." -ForegroundColor Cyan
    Write-Host ""
}

Main