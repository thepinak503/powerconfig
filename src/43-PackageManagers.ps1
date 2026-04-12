# PowerConfig Package Managers - Unified Logic
# Handling Winget, Scoop, Chocolatey, plus Linux muscle-memory wrappers

$HasScoop = $null -ne (Get-Command scoop -ErrorAction SilentlyContinue).Source
$HasChoco = $null -ne (Get-Command choco -ErrorAction SilentlyContinue).Source
$HasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue).Source

#region CROSS-PLATFORM WRAPPERS (Linux Muscle Memory)
function apt { winget @args }
function brew {
    if ($HasScoop) { scoop @args }
    elseif ($HasChoco) { choco @args }
    else { winget @args }
}
function pacman { choco @args }
#endregion

#region UNIVERSAL ACTIONS
function pinstall {
    param([string]$Package)
    if ($HasWinget) { winget install --silent $Package }
    elseif ($HasScoop) { scoop install $Package }
    elseif ($HasChoco) { choco install -y $Package }
}

function pupdate {
    if ($HasWinget) { winget upgrade --all --silent }
    if ($HasScoop) { scoop update * }
    if ($HasChoco) { choco upgrade all -y }
}
#endregion

#region LANGUAGE MANAGERS
function Invoke-Pip {
    param([string[]]$Args)
    if (Get-Command pip -EA SilentlyContinue) { pip.exe @Args }
    else { python -m pip @Args }
}

function Invoke-Npm {
    param([string[]]$Args)
    if (Get-Command npm -EA SilentlyContinue) { npm @Args }
    else { Write-Error "npm not found" }
}

function Invoke-Cargo {
    param([string[]]$Args)
    if (Get-Command cargo -EA SilentlyContinue) { cargo @Args }
    else { Write-Error "cargo not found" }
}
#endregion

#region SPECIFIC MANAGERS (Shortcuts)
if ($HasWinget) {
    function w { winget @args }
    function wi { winget install @args }
    function wun { winget uninstall @args }
    function wup { winget upgrade @args }
}

if ($HasScoop) {
    function s { scoop @args }
    function si { scoop install @args }
    function su { scoop update @args }
}

if ($HasChoco) {
    function ch { choco @args }
    function chi { choco install $args }
    function cha { choco upgrade all -y }
}
#endregion
