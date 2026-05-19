$ErrorActionPreference = "Continue"
if (-not $IsWindows) { Write-Host "PowerConfig is Windows-only." -ForegroundColor Yellow; exit 0 }

if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "|       POWERCONFIG FULL INSTALLER           |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan

$RepoUrl = "https://github.com/thepinak503/powerconfig"
$InstallDir = "$env:USERPROFILE\Documents\Git\powerconfig"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements | Out-Null
}

if (-not (Test-Path $InstallDir)) {
    $parent = Split-Path $InstallDir -Parent
    if (-not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory -Force | Out-Null }
    Write-Host "Cloning..." -ForegroundColor Cyan
    git clone --depth=1 $RepoUrl $InstallDir | Out-Null
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
    Set-Content -Path (Join-Path $t.Dir "Microsoft.PowerShell_profile.ps1") -Value $profileContent -Encoding UTF8
    Write-Host "  [OK] $($t.Name)" -ForegroundColor Green
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install -e --id Starship.Starship --accept-source-agreements --accept-package-agreements | Out-Null
    winget install -e --id ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements | Out-Null
}

Write-Host "[OK] Installation complete!" -ForegroundColor Green
Write-Host "Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
