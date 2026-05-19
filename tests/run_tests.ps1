param(
    [switch]$Fast,
    [switch]$Quiet,
    [switch]$SkipLoad,
    [string]$Report
)

$ROOT = Split-Path $PSScriptRoot -Parent
$TestScript = Join-Path $ROOT "bin\test_all.ps1"

if (-not (Test-Path $TestScript)) {
    Write-Host "Test script not found: $TestScript" -ForegroundColor Red
    exit 1
}

Write-Host "+--------------------------------------------+" -ForegroundColor Magenta
Write-Host "|       POWERCONFIG TEST RUNNER v1.0          |" -ForegroundColor Magenta
Write-Host "+--------------------------------------------+" -ForegroundColor Magenta

$argsList = @()
if ($Fast) { $argsList += "-Fast" }
if ($Quiet) { $argsList += "-Quiet" }
if ($SkipLoad) { $argsList += "-SkipLoad" }

$start = Get-Date
& $TestScript @argsList
$elapsed = (Get-Date) - $start

Write-Host "`nElapsed: $($elapsed.TotalSeconds.ToString('F2'))s" -ForegroundColor Cyan

if ($Report) {
    $allResults = @()
    $allFiles = Get-ChildItem $ROOT -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notlike "*\.git*" }
    $allResults += [PSCustomObject]@{Check="Files parsed"; Value=$allFiles.Count}
    $allResults += [PSCustomObject]@{Check="Elapsed (s)"; Value=$elapsed.TotalSeconds.ToString('F2')}
    $allResults | Export-Csv -Path $Report -NoTypeInformation
    Write-Host "Report saved: $Report" -ForegroundColor Cyan
}
