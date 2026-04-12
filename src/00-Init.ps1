# PowerConfig Init - Optimization & Maintenance
# Inspired by Chris Titus Tech and Pinak503

# Opt-out of telemetry
$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'

# Performance: Ensure TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Maintenance: Update Profile (CIT-style logic)
function Update-PowerConfig {
    Write-Host "Checking for PowerConfig updates..." -ForegroundColor Cyan
    git -C $env:POWERCONFIG_DIR pull origin main
    Write-Host "Update complete. Please restart your shell." -ForegroundColor Green
}

# Maintenance: Clear Cache
function Clear-Cache {
    Write-Host "Clearing User and System Temp..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cache cleared!" -ForegroundColor Green
}
