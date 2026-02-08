# PowerConfig Aliases
# Comprehensive PowerShell aliases with Scoop, Chocolatey, and Winget support

#region Navigation
Set-Alias -Name .. -Value Go-Up
Set-Alias -Name ... -Value Go-Up2
Set-Alias -Name .... -Value Go-Up3
Set-Alias -Name home -Value Go-Home

function Go-Up { Set-Location .. }
function Go-Up2 { Set-Location ..\.. }
function Go-Up3 { Set-Location ..\..\.. }
function Go-Home { Set-Location ~ }

function desk { Set-Location ~/Desktop }
function docs { Set-Location ~/Documents }
function dl { Set-Location ~/Downloads }
function pics { Set-Location ~/Pictures }
function vids { Set-Location ~/Videos }
#endregion

#region Listing
function List-All { param([string]$Path = ".") Get-ChildItem -Path $Path -Force }
function List-Detailed { param([string]$Path = ".") Get-ChildItem -Path $Path -Force | Format-List }
function List-Hidden { param([string]$Path = ".") Get-ChildItem -Path $Path -Hidden }

Set-Alias -Name l -Value List-All
Set-Alias -Name la -Value List-All
Set-Alias -Name ll -Value List-Detailed
Set-Alias -Name lh -Value List-Hidden
#endregion

#region File Operations
function Make-Directory {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force
    Set-Location $Path
}

function Touch-File {
    param([string]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path -Force
    }
}

Set-Alias -Name mkdir -Value Make-Directory
Set-Alias -Name touch -Value Touch-File
Set-Alias -Name which -Value Get-Command
Set-Alias -Name grep -Value Select-String
#endregion

#region Editors
Set-Alias -Name v -Value $env:EDITOR
Set-Alias -Name vi -Value $env:EDITOR
Set-Alias -Name vim -Value $env:EDITOR
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name q -Value Exit
#endregion

#region System
function sysinfo {
    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory, CsProcessors, WindowsInstallDateFromRegistry
}

function myip {
    Write-Host "Internal IPs:" -ForegroundColor Cyan
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1" } | Select-Object InterfaceAlias, IPAddress | Format-Table
    
    Write-Host "`nExternal IP:" -ForegroundColor Cyan
    try {
        $external = Invoke-RestMethod -Uri "https://ifconfig.me" -TimeoutSec 5
        Write-Host "  $external" -ForegroundColor Green
    } catch {
        Write-Host "  Could not retrieve external IP" -ForegroundColor Red
    }
}

function flushdns { Clear-DnsClientCache }
function reload { . $PROFILE }

Set-Alias -Name df -Value Get-Volume
Set-Alias -Name ps -Value Get-Process
Set-Alias -Name top -Value Get-Process
function env { Get-ChildItem Env: }
#endregion

#region Cross-Platform Utilities
# Platform detection
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $script:IsWindows = $true
} else {
    $script:IsWindows = $IsWindows
    $script:IsMacOS = $IsMacOS
    $script:IsLinux = $IsLinux
}

# Cross-platform editor aliases
if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Alias -Name v -Value code
    Set-Alias -Name vi -Value code
    Set-Alias -Name vim -Value code
} elseif (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name v -Value nvim
    Set-Alias -Name vi -Value nvim
    Set-Alias -Name vim -Value nvim
} elseif (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Alias -Name v -Value vim
    Set-Alias -Name vi -Value vim
    Set-Alias -Name vim -Value vim
} else {
    if ($IsWindows) {
        Set-Alias -Name v -Value notepad
        Set-Alias -Name vi -Value notepad
        Set-Alias -Name vim -Value notepad
    } else {
        Set-Alias -Name v -Value nano
        Set-Alias -Name vi -Value vi
        Set-Alias -Name vim -Value vi
    }
}

# Cross-platform file manager
function explore {
    param([string]$Path = ".")
    
    if ($IsWindows) {
        explorer.exe $Path
    } elseif ($IsMacOS) {
        open $Path
    } else {
        if (Get-Command xdg-open -ErrorAction SilentlyContinue) {
            xdg-open $Path
        } else {
            Write-Error "No suitable file manager found"
        }
    }
}

# Cross-platform hosts file editor
function hosts {
    if ($IsWindows) {
        & $env:EDITOR "C:\Windows\System32\drivers\etc\hosts"
    } elseif ($IsMacOS) {
        & $env:EDITOR "/etc/hosts"
    } else {
        sudo $env:EDITOR "/etc/hosts"
    }
}

# Cross-platform trash emptying
function emptytrash {
    if ($IsWindows) {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "Recycle Bin emptied" -ForegroundColor Green
    } elseif ($IsMacOS) {
        osascript -e 'tell application "Finder" to empty trash'
        Write-Host "Trash emptied" -ForegroundColor Green
    } else {
        Write-Host "Linux trash emptying not implemented" -ForegroundColor Yellow
    }
}

# Cross-platform recycle/trash access
function recycle {
    if ($IsWindows) {
        explorer.exe shell:RecycleBinFolder
    } elseif ($IsMacOS) {
        open ~/.Trash
    } else {
        if (Test-Path ~/.local/share/Trash) {
            explore ~/.local/share/Trash
        } else {
            Write-Error "Trash directory not found"
        }
    }
}
#endregion

#region Windows-Specific Utilities
if ($IsWindows) {
    Set-Alias -Name explorer -Value explorer.exe
    Set-Alias -Name notepad -Value notepad.exe
    Set-Alias -Name calc -Value calc.exe
    Set-Alias -Name taskmgr -Value taskmgr.exe
    Set-Alias -Name mspaint -Value mspaint.exe
    
    function services { services.msc }
    function envvars { rundll32 sysdm.cpl,EditEnvironmentVariables }
    function firewall { wf.msc }
    function devmgmt { devmgmt.msc }
    function diskmgmt { diskmgmt.msc }
    function tasksched { taskschd.msc }
    function appwiz { appwiz.cpl }
    function inetcpl { inetcpl.cpl }
    function ncpa { ncpa.cpl }
    function sysdm { sysdm.cpl }
    function winver { winver.exe }
    
    Write-Host "✓ Windows-specific aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region macOS-Specific Utilities
if ($IsMacOS) {
    function show-hidden-files {
        defaults write com.apple.finder AppleShowAllFiles YES
        killall Finder
        Write-Host "Hidden files shown" -ForegroundColor Green
    }

    function hide-hidden-files {
        defaults write com.apple.finder AppleShowAllFiles NO
        killall Finder
        Write-Host "Hidden files hidden" -ForegroundColor Green
    }

    function lock-screen {
        /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
    }

    Write-Host "✓ macOS-specific aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Linux-Specific Utilities
if ($IsLinux) {
    function apt-update {
        sudo apt update && sudo apt upgrade -y
    }

    function dnf-update {
        sudo dnf update -y
    }

    function pacman-update {
        sudo pacman -Syu --noconfirm
    }

    Write-Host "✓ Linux-specific aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Utilities
function reload { . $PROFILE }
function path { $env:Path -split ';' }
function aliases { Get-Alias | Select-Object Name, Definition | Sort-Object Name }
function functions { Get-ChildItem Function: | Select-Object Name | Sort-Object Name }
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force
    Set-Location $Path
}
function bak {
    param([string]$File)
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item -Path $File -Destination "$File.bak.$timestamp"
}
function timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }
function today { Get-Date -Format "yyyy-MM-dd" }
function week { Get-Date -UFormat "%V" }
#endregion

#endregion
