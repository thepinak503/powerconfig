# =============================================================================
# PowerConfig - The Ultimate PowerShell Experience
# Entry Point: Microsoft.PowerShell_profile.ps1
# Inspired by Chris Titus Tech & thepinak503/dotfiles
# =============================================================================

# Opt-out of telemetry
$env:POWERSHELL_TELEMETRY_OPTOUT = "true"

# Add starship to PATH if installed
$starshipBin = "$env:ProgramFiles\starship\bin"
if ((Test-Path $starshipBin) -and ($env:Path -notlike "*$starshipBin*")) {
    $env:Path = "$starshipBin;$env:Path"
}

# Define Root Directory
$env:POWERCONFIG_DIR = $PSScriptRoot

# -----------------------------------------------------------------------------
# SOURCE-ALL LOGIC (Bash-style)
# -----------------------------------------------------------------------------
$SRC_DIR = Join-Path $env:POWERCONFIG_DIR "src"
$SourceFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.ps1" | Sort-Object Name

foreach ($file in $SourceFiles) {
    if (Test-Path $file.FullName) {
        . $file.FullName
    }
}

# -----------------------------------------------------------------------------
# DOCS HELPER
# -----------------------------------------------------------------------------
function Show-PowerDocs {
    $DocsPath = Join-Path $env:POWERCONFIG_DIR "docs/index.html"
    Start-Process $DocsPath
}

# -----------------------------------------------------------------------------
# LOCAL EXTENSIONS
# -----------------------------------------------------------------------------
$LOCAL_PROFILE = Join-Path $env:POWERCONFIG_DIR "profile.local.ps1"
if (Test-Path $LOCAL_PROFILE) {
    . $LOCAL_PROFILE
}

# -----------------------------------------------------------------------------
# STARTUP
# -----------------------------------------------------------------------------
if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch }
