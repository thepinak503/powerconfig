# PowerConfig Package Managers
# Scoop, Chocolatey, and Winget aliases and functions

#region Scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    # Scoop Shortcuts
    function s { scoop $args }
    function si { scoop install $args }
    function sun { scoop uninstall $args }
    function su { scoop update $args }
    function sup { scoop update * }
    function ss { scoop search $args }
    function sls { scoop list }
    function sst { scoop status }
    function sc { scoop cleanup * }
    function sb { scoop bucket list }
    function sba { scoop bucket add $args }
    function sbr { scoop bucket rm $args }
    function sinfo { scoop info $args }
    function sck { scoop checkup }
    function sx { scoop export }
    function simp { scoop import $args }
    function shold { scoop hold $args }
    function sunhold { scoop unhold $args }
    function sreset { scoop reset $args }
    function sprefix { scoop prefix $args }
    function swhich { scoop which $args }
    function scache { scoop cache rm * }
    
    # Scoop aliases for common packages
    function sgit { scoop install git }
    function spython { scoop install python }
    function snode { scoop install nodejs }
    function s7z { scoop install 7zip }
    function swget { scoop install wget }
    function scurl { scoop install curl }
    function sgrep { scoop install grep }
    function sless { scoop install less }
    function sopenssh { scoop install openssh }
    function sgsudo { scoop install gsudo }
    
    Write-Host "✓ Scoop aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    # Chocolatey Shortcuts
    function ch { choco $args }
    function chi { choco install $args }
    function chun { choco uninstall $args }
    function chup { choco upgrade $args }
    function cha { choco upgrade all }
    function chs { choco search $args }
    function chls { choco list --local-only }
    function cho { choco outdated }
    function chp { choco pin $args }
    function chf { choco feature $args }
    function chsrc { choco source $args }
    function chconfig { choco config $args }
    function chk { choco pack $args }
    function chpush { choco push $args }
    function chinfo { choco info $args }
    
    # Chocolatey with confirmation bypass
    function chiy { choco install -y $args }
    function chuny { choco uninstall -y $args }
    function chupy { choco upgrade -y $args }
    function chay { choco upgrade all -y }
    
    # Chocolatey maintenance
    function chclean { choco cache remove }
    function choptimize { choco optimize }
    
    Write-Host "✓ Chocolatey aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Winget (Windows Package Manager)
if (Get-Command winget -ErrorAction SilentlyContinue) {
    # Winget Shortcuts
    function w { winget $args }
    function wi { winget install $args }
    function wun { winget uninstall $args }
    function wup { winget upgrade $args }
    function wua { winget upgrade --all }
    function ws { winget search $args }
    function wls { winget list }
    function wo { winget outdated }
    function wshow { winget show $args }
    function wsource { winget source $args }
    function wexport { winget export -o $args }
    function wimport { winget import -i $args }
    function whash { winget hash -f $args }
    function wvalidate { winget validate $args }
    function wsettings { winget settings }
    function wfeatures { winget features }
    
    # Winget with silent install
    function wiy { winget install --silent $args }
    function wupy { winget upgrade --silent --all }
    
    # Winget search by category
    function wdev { winget search "development" }
    function wutil { winget search "utility" }
    function wmedia { winget search "media" }
    
    Write-Host "✓ Winget aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Universal Package Aliases
# These work with any available package manager
function pinstall {
    <#
    .SYNOPSIS
        Universal package install (tries Scoop, then Chocolatey, then Winget)
    .PARAMETER Package
        Package name to install
    #>
    param([Parameter(Mandatory)][string]$Package)
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop install $Package
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install -y $Package
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --silent $Package
    } else {
        Write-Error "No package manager found (Scoop, Chocolatey, Winget)"
    }
}

function psearch {
    <#
    .SYNOPSIS
        Universal package search
    .PARAMETER Query
        Package to search for
    #>
    param([Parameter(Mandatory)][string]$Query)
    
    Write-Host "Searching Scoop..." -ForegroundColor Cyan
    scoop search $Query 2>$null
    
    Write-Host "`nSearching Chocolatey..." -ForegroundColor Cyan
    choco search $Query 2>$null
    
    Write-Host "`nSearching Winget..." -ForegroundColor Cyan
    winget search $Query 2>$null
}

function pupdate {
    <#
    .SYNOPSIS
        Update all packages across all managers
    #>
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Updating Scoop packages..." -ForegroundColor Yellow
        scoop update *
    }
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "`nUpdating Chocolatey packages..." -ForegroundColor Yellow
        choco upgrade all -y
    }
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "`nUpdating Winget packages..." -ForegroundColor Yellow
        winget upgrade --all --silent
    }
}

function pclean {
    <#
    .SYNOPSIS
        Clean package manager caches
    #>
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop cleanup *
        scoop cache rm *
    }
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco cache remove
    }
}
#endregion

#region Scoop Bucket Management
function Install-ScoopBuckets {
    <#
    .SYNOPSIS
        Install common Scoop buckets
    #>
    $buckets = @(
        "extras",
        "versions",
        "nirsoft",
        "sysinternals",
        "php",
        "nerd-fonts",
        "nonportable",
        "java",
        "games"
    )
    
    foreach ($bucket in $buckets) {
        Write-Host "Adding bucket: $bucket" -ForegroundColor Yellow
        scoop bucket add $bucket 2>$null
    }
}

function Install-ScoopEssentials {
    <#
    .SYNOPSIS
        Install essential Scoop packages
    #>
    $essentials = @(
        "7zip",
        "git",
        "curl",
        "wget",
        "grep",
        "less",
        "make",
        "gcc",
        "nodejs",
        "python",
        "go",
        "rust",
        "fzf",
        "ripgrep",
        "fd",
        "bat",
        "eza",
        "delta",
        "starship",
        "zoxide"
    )
    
    foreach ($pkg in $essentials) {
        Write-Host "Installing: $pkg" -ForegroundColor Yellow
        scoop install $pkg
    }
}
#endregion

#region Chocolatey Helpers
function Install-ChocoEssentials {
    <#
    .SYNOPSIS
        Install essential Chocolatey packages
    #>
    $essentials = @(
        "7zip.install",
        "git.install",
        "curl",
        "wget",
        "make",
        "nodejs.install",
        "python3",
        "golang",
        "rust",
        "fzf",
        "ripgrep",
        "fd",
        "bat",
        "delta",
        "starship",
        "zoxide",
        "microsoft-windows-terminal",
        "powertoys",
        "vscode"
    )
    
    foreach ($pkg in $essentials) {
        Write-Host "Installing: $pkg" -ForegroundColor Yellow
        choco install -y $pkg
    }
}

function chocofull {
    <#
    .SYNOPSIS
        Full Chocolatey setup with essentials
    #>
    Install-ChocoEssentials
}
#endregion

#region Package Manager Info
function pkginfo {
    <#
    .SYNOPSIS
        Show installed package managers
    #>
    $managers = @()
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $version = (scoop --version) | Select-Object -First 1
        $managers += [PSCustomObject]@{ Manager = "Scoop"; Version = $version; Status = "✓ Installed" }
    }
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $version = (choco --version)
        $managers += [PSCustomObject]@{ Manager = "Chocolatey"; Version = $version; Status = "✓ Installed" }
    }
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $version = (winget --version)
        $managers += [PSCustomObject]@{ Manager = "Winget"; Version = $version; Status = "✓ Installed" }
    }
    
    if ($managers.Count -eq 0) {
        Write-Host "No package managers installed!" -ForegroundColor Red
        Write-Host "Install Scoop: iwr -useb get.scoop.sh | iex" -ForegroundColor Yellow
        Write-Host "Install Chocolatey: https://chocolatey.org/install" -ForegroundColor Yellow
    } else {
        $managers | Format-Table -AutoSize
    }
}
#endregion
