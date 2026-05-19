param([switch]$Force)
$ErrorActionPreference = "Continue"
if (-not $IsWindows) { Write-Host "PowerConfig is Windows-only." -ForegroundColor Yellow; exit 0 }

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$RepoUrl = "https://github.com/thepinak503/powerconfig"
$InstallDir = "$env:USERPROFILE\Documents\Git\powerconfig"

Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "|       POWERCONFIG INSTALLER                |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    try { winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null } catch {}
}

if (-not (Test-Path $InstallDir)) {
    $parent = Split-Path $InstallDir -Parent
    if (-not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory -Force | Out-Null }
    Write-Host "Cloning PowerConfig..." -ForegroundColor Cyan
    git clone --depth=1 $RepoUrl $InstallDir 2>&1 | Out-Null
} else {
    Write-Host "Updating PowerConfig..." -ForegroundColor Cyan
    git -C $InstallDir pull 2>&1 | Out-Null
}

$profileContent = @"
`$env:POWERCONFIG_DIR = `"$InstallDir`"
. (Join-Path `$env:POWERCONFIG_DIR `"Microsoft.PowerShell_profile.ps1`")
"@

$targets = @(
    @{Name="PowerShell 7+"; Dir="$env:USERPROFILE\Documents\PowerShell"},
    @{Name="PowerShell 5.1"; Dir="$env:USERPROFILE\Documents\WindowsPowerShell"}
)

foreach ($t in $targets) {
    if (-not (Test-Path $t.Dir)) { New-Item -Path $t.Dir -ItemType Directory -Force | Out-Null }
    $profilePath = Join-Path $t.Dir "Microsoft.PowerShell_profile.ps1"
    Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
    Write-Host "  [OK] $($t.Name)" -ForegroundColor Green
}

Write-Host "[OK] Installation complete!" -ForegroundColor Green
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
