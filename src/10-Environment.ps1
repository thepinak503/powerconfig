# PowerConfig Environment - Variables & Paths

# Define standard editor (CTT-style logic)
if (-not $env:EDITOR) {
    if (Get-Command nvim -EA SilentlyContinue) { $env:EDITOR = "nvim" }
    elseif (Get-Command code -EA SilentlyContinue) { $env:EDITOR = "code --wait" }
    else { $env:EDITOR = "notepad" }
}

# Add local bin to path
$LocalBin = Join-Path $env:POWERCONFIG_DIR "bin"
if ($env:PATH -notlike "*$LocalBin*") {
    $env:PATH = "$LocalBin;$env:PATH"
}

# Standard Locations
$global:CD_PROJECTS = Join-Path $HOME "projects"
$global:CD_CODE = Join-Path $HOME "code"
