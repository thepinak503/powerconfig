Write-Host "=== PowerConfig Health Check ===" -ForegroundColor Cyan
Write-Host "OS: $env:DOTFILES_OS"
Write-Host "Shell: $env:POWERCONFIG_SHELL"
Write-Host "Mode: $env:POWERCONFIG_MODE"
Write-Host "Dir: $env:POWERCONFIG_DIR"
Write-Host "Profile: $PROFILE"
Write-Host ""

$coreDir = Join-Path $env:POWERCONFIG_DIR "core"
$files = @('__cache.ps1','Detection.ps1','Tools.ps1','Aliases.ps1','Functions.ps1','Universal.ps1','Battery.ps1','Logging.ps1','SSHAgent.ps1','WinTweaks.ps1')
foreach ($f in $files) {
    $p = Join-Path $coreDir $f
    if (Test-Path $p) {
        Write-Host "[OK] $f" -ForegroundColor Green
    } else {
        Write-Host "[!] $f missing" -ForegroundColor Red
    }
}

$missing = ($global:POWERCONFIG_TOOLS.Keys | Where-Object { -not $global:POWERCONFIG_TOOLS[$_] }).Count
$total = $global:POWERCONFIG_TOOLS.Count
Write-Host "`nTools: $($total - $missing)/$total available"
if ($missing -gt 0) { Write-Host "[!] $missing tools missing - run 'dotinstall'" -ForegroundColor Yellow }
