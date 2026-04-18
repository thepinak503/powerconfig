# =============================================================================
# PowerConfig Installer - STEP 2
# Full Installation (after Git is ready)
# =============================================================================

$ErrorActionPreference = "Continue"

if (-not $IsWindows) {
    Write-Host "This installer is for Windows only." -ForegroundColor Yellow
    exit 0
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
            Write-Host "  [OK] $FontDisplayName installed" -ForegroundColor Green
        } else {
            Write-Host "  [SKIP] $FontDisplayName already installed" -ForegroundColor Gray
        }
    } catch { Write-Host "  [WARN] Font: $_" -ForegroundColor Yellow }
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
            Write-Host "  [OK] Windows Terminal font set" -ForegroundColor Green
        } catch { }
    }
}

function Install-IfNeeded {
    param([string]$Name, [string]$WingetId)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing $Name..." -ForegroundColor Cyan
        try { winget install -e --id $WingetId --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null } catch { }
    } else {
        Write-Host "  [SKIP] $Name already installed" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       POWERCONFIG - STEP 2: FULL INSTALL         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-InternetConnection)) {
    Write-Host "[ERROR] Internet required!" -ForegroundColor Red
    exit 1
}

Write-Host "[CHECK] Cloning PowerConfig..." -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    $gitDir = Split-Path $InstallDir
    if (-not (Test-Path $gitDir)) { New-Item -Path $gitDir -ItemType Directory -Force | Out-Null }
    git clone --depth=1 $RepoUrl $InstallDir 2>&1 | Out-Null
}

if (-not (Test-Path $InstallDir)) {
    Write-Host "[ERROR] Clone failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Cloned: $InstallDir" -ForegroundColor Green

Write-Host ""
Write-Host "[INFO] Installing to PowerShell folders..." -ForegroundColor Cyan

$profileContent = @'
# PowerConfig Profile v7.1
$env:POWERCONFIG_DIR = $PSScriptRoot

$env:STARSHIP_CONFIG = Join-Path ($env:USERPROFILE) ".config\starship.toml"

$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) {
    $env:Path = "$starshipBin;$env:Path"
}

$DOTFILES_STATE_DIR = "$env:USERPROFILE\.config\powerconfig-state"
if (-not (Test-Path $DOTFILES_STATE_DIR)) {
    New-Item -ItemType Directory -Path $DOTFILES_STATE_DIR -Force | Out-Null
}

$SRC_DIR = Join-Path $PSScriptRoot "src"
$SourceFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.ps1" -ErrorAction SilentlyContinue | Sort-Object Name

foreach ($file in $SourceFiles) {
    if (Test-Path $file.FullName) {
        . $file.FullName
    }
}

$env:POWERCONFIG_MODE = "standard"
'@

$allShells = @(
    @{Name="PowerShell 7+"; Dir="$env:USERPROFILE\Documents\PowerShell"},
    @{Name="PowerShell 5.1"; Dir="$env:USERPROFILE\Documents\WindowsPowerShell"}
)

foreach ($shell in $allShells) {
    $targetDir = $shell.Dir
    
    Write-Host "  Installing to $($shell.Name)..." -ForegroundColor Yellow
    
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }
    
    $profilePath = Join-Path $targetDir "profile.ps1"
    $hostProfile = Join-Path $targetDir "Microsoft.PowerShell_profile.ps1"
    $srcDir = Join-Path $targetDir "src"
    
    New-Item -Path $profilePath -Type File -Force | Out-Null
    Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
    
    New-Item -Path $hostProfile -Type File -Force | Out-Null
    Set-Content -Path $hostProfile -Value $profileContent -Encoding UTF8
    
    if (Test-Path $srcDir) { Remove-Item -Path $srcDir -Recurse -Force }
    Copy-Item -Path (Join-Path $InstallDir "src") -Destination $srcDir -Recurse -Force
    
    Write-Host "    [OK] profile.ps1, src/" -ForegroundColor Green
}

$configDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }

$starshipSource = Join-Path $InstallDir "apps\starship\starship.toml"
if (Test-Path $starshipSource) {
    Copy-Item -Path $starshipSource -Destination "$configDir\starship.toml" -Force
    Write-Host "[OK] Starship config" -ForegroundColor Green
}

Write-Host ""
Write-Host "[INFO] Installing dependencies..." -ForegroundColor Cyan

$deps = @(
    @{Name="starship"; Id="Starship.Starship"},
    @{Name="zoxide"; Id="ajeetdsouza.zoxide"}
)

foreach ($dep in $deps) {
    Install-IfNeeded -Name $dep.Name -WingetId $dep.Id
}

Write-Host "  Installing Terminal-Icons module..." -ForegroundColor Cyan
try { 
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force 2>&1 | Out-Null
        Write-Host "  [OK] Terminal-Icons installed" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Terminal-Icons already installed" -ForegroundColor Gray
    }
} catch { }

Write-Host ""
Write-Host "[INFO] Installing fonts..." -ForegroundColor Cyan
Install-Font
Set-WindowsTerminalFont

Write-Host ""
Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "[SUCCESS] FULL INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "═════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to:" -ForegroundColor Cyan
Write-Host "  - Documents\PowerShell\" -ForegroundColor White
Write-Host "  - Documents\WindowsPowerShell\" -ForegroundColor White
Write-Host ""
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
Write-Host ""

function Get-Help {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Available Commands:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Navigation:" -ForegroundColor White
    Write-Host "  mkcd <dir>  - Make dir and cd" -ForegroundColor Gray
    Write-Host "  back       - Go back" -ForegroundColor Gray
    Write-Host "  cddesk     - Go to Desktop" -ForegroundColor Gray
    Write-Host "  cddl      - Go to Downloads" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Git:" -ForegroundColor White
    Write-Host "  gcap <msg> - Add, commit, push" -ForegroundColor Gray
    Write-Host "  gcom      - Add, commit" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Files:" -ForegroundColor White
    Write-Host "  backup <f> - Backup file" -ForegroundColor Gray
    Write-Host "  extract <f> - Extract archive" -ForegroundColor Gray
    Write-Host "  touch <f>  - Create file" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Tools:" -ForegroundColor White
    Write-Host "  sysinfo    - System info (fastfetch)" -ForegroundColor Gray
    Write-Host "  genpass   - Generate password" -ForegroundColor Gray
    Write-Host "  myip     - Show IP" -ForegroundColor Gray
    Write-Host "  weather  - Show weather" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Docker:" -ForegroundColor White
    Write-Host "  dps, dpa, dimg, dlogs, dex" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Kubernetes:" -ForegroundColor White
    Write-Host "  k, kgp, kgs, kd, kl, kex, ka" -ForegroundColor Gray
    Write-Host "" -ForegroundColor White
    Write-Host "Mode:" -ForegroundColor White
    Write-Host "  chmode [minimal|standard]" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
}

Get-Help
Write-Host ""