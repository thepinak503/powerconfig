$env:POWERCONFIG_DIR = $PSScriptRoot
$env:POWERSHELL_TELEMETRY_OPTOUT = "true"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$coreDir = Join-Path $env:POWERCONFIG_DIR "core"
$files = @(
    "__cache.ps1",
    "Detection.ps1",
    "Tools.ps1",
    "Aliases.ps1",
    "Functions.ps1",
    "Universal.ps1",
    "Battery.ps1",
    "Logging.ps1",
    "SSHAgent.ps1",
    "WinTweaks.ps1"
)
foreach ($f in $files) {
    $path = Join-Path $coreDir $f
    if (Test-Path $path) {
        try { . $path } catch { Write-Host "[WARN] Failed to load ${f}: $($_.Exception.Message)" -ForegroundColor Yellow }
    }
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if ($Cmds.zoxide) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

if ($PSVersionTable.PSEdition -eq 'Core') {
    Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue

$localProfile = Join-Path $env:POWERCONFIG_DIR "profile.local.ps1"
if (Test-Path $localProfile) { . $localProfile }

if (Get-Command fastfetch -ErrorAction SilentlyContinue -and -not $env:POWERCONFIG_FASTFETCH_RUN) {
    $env:POWERCONFIG_FASTFETCH_RUN = "1"
    fastfetch
}

Write-Host "PowerConfig loaded | Mode: $env:POWERCONFIG_MODE" -ForegroundColor Cyan
Write-Host "Run 'Show-PowerConfigHelp' for available commands" -ForegroundColor Yellow
