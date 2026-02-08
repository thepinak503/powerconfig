# PowerConfig Cross-Platform System
# Universal utilities for Windows, macOS, and Linux

#region Platform Detection
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $script:IsWindows = $true
} else {
    $script:IsWindows = $IsWindows
    $script:IsMacOS = $IsMacOS
    $script:IsLinux = $IsLinux
}
#endregion

#region Cross-Platform File System Paths
function Get-HomePath {
    if ($IsWindows) {
        return $env:USERPROFILE
    } else {
        return $env:HOME
    }
}

function Get-ConfigPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\AppData\Roaming"
    } elseif ($IsMacOS) {
        return "$homePath/Library/Application Support"
    } else {
        return "$homePath/.config"
    }
}

function Get-DesktopPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Desktop"
    } elseif ($IsMacOS) {
        return "$homePath/Desktop"
    } else {
        return "$homePath/Desktop"
    }
}

function Get-DocumentsPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Documents"
    } elseif ($IsMacOS) {
        return "$homePath/Documents"
    } else {
        return "$homePath/Documents"
    }
}

function Get-DownloadsPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Downloads"
    } elseif ($IsMacOS) {
        return "$homePath/Downloads"
    } else {
        return "$homePath/Downloads"
    }
}

function Get-PicturesPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Pictures"
    } elseif ($IsMacOS) {
        return "$homePath/Pictures"
    } else {
        return "$homePath/Pictures"
    }
}

function Get-VideosPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Videos"
    } elseif ($IsMacOS) {
        return "$homePath/Movies"
    } else {
        return "$homePath/Videos"
    }
}

function Get-MusicPath {
    $homePath = Get-HomePath
    
    if ($IsWindows) {
        return "$homePath\Music"
    } elseif ($IsMacOS) {
        return "$homePath/Music"
    } else {
        return "$homePath/Music"
    }
}

function Get-TempPath {
    if ($IsWindows) {
        return $env:TEMP
    } else {
        return "/tmp"
    }
}
#endregion

#region Cross-Platform Navigation Functions
function home { Set-Location (Get-HomePath) }
function desktop { Set-Location (Get-DesktopPath) }
function documents { Set-Location (Get-DocumentsPath) }
function downloads { Set-Location (Get-DownloadsPath) }
function pics { Set-Location (Get-PicturesPath) }
function videos { Set-Location (Get-VideosPath) }
function music { Set-Location (Get-MusicPath) }
function tmp { Set-Location (Get-TempPath) }

function hosts {
    if ($IsWindows) {
        & $env:EDITOR "C:\Windows\System32\drivers\etc\hosts"
    } elseif ($IsMacOS) {
        & $env:EDITOR "/etc/hosts"
    } else {
        sudo $env:EDITOR "/etc/hosts"
    }
}
#endregion

#region Cross-Platform System Utilities
function sysinfo {
    if ($IsWindows) {
        $info = Get-ComputerInfo
        [PSCustomObject]@{
            "OS" = $info.WindowsProductName
            "Version" = $info.WindowsVersion
            "Architecture" = $info.OsArchitecture
            "Total RAM" = "{0:N2} GB" -f ($info.TotalPhysicalMemory / 1GB)
            "Processors" = $info.CsProcessors.Count
            "Boot Time" = $info.OsLastBootUpTime
        } | Format-List
    } elseif ($IsMacOS) {
        system_profiler SPHardwareDataType | Select-String "Model Name", "Processor", "Memory", "System Serial Number"
    } else {
        lscpu | Select-String "Model name", "CPU(s)", "Memory"
        free -h
    }
}

function myip {
    Write-Host "Internal IPs:" -ForegroundColor Cyan
    
    if ($IsWindows) {
        Get-NetIPAddress -AddressFamily IPv4 | 
            Where-Object { $_.IPAddress -ne "127.0.0.1" } |
            Select-Object InterfaceAlias, IPAddress |
            Format-Table
    } else {
        ip addr show | Select-String "inet " | ForEach-Object {
            $parts = $_ -split '\s+'
            "$($parts[1]) $($parts[-1])"
        }
    }
    
    Write-Host "`nExternal IP:" -ForegroundColor Cyan
    try {
        $external = Invoke-RestMethod -Uri "https://ifconfig.me" -TimeoutSec 5
        Write-Host "  $external" -ForegroundColor Green
    } catch {
        Write-Host "  Could not retrieve" -ForegroundColor Red
    }
}

function flushdns {
    if ($IsWindows) {
        Clear-DnsClientCache
    } elseif ($IsMacOS) {
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    } else {
        sudo systemd-resolve --flush-caches
    }
    Write-Host "DNS cache cleared" -ForegroundColor Green
}

function emptytrash {
    if ($IsWindows) {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "Recycle Bin emptied" -ForegroundColor Green
    } elseif ($IsMacOS) {
        osascript -e 'tell application "Finder" to empty trash'
        Write-Host "Trash emptied" -ForegroundColor Green
    } else {
        Write-Host "Linux trash emptying not implemented" -ForegroundColor Yellow
        # Could implement: rm -rf ~/.local/share/Trash/*
    }
}

function reload {
    . $PROFILE
}
#endregion

#region Cross-Platform Process Management
function psgrep {
    param([Parameter(Mandatory)][string]$Name)
    
    if ($IsWindows) {
        Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
            Select-Object Id, ProcessName, CPU, WorkingSet |
            Format-Table -AutoSize
    } else {
        ps aux | Select-String $Name
    }
}

function fkill {
    param([Parameter(Mandatory)][string]$Name)
    
    if ($IsWindows) {
        Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
            Stop-Process -Force
        Write-Host "Processes matching '$Name' terminated" -ForegroundColor Green
    } else {
        pkill -f $Name
        Write-Host "Processes matching '$Name' terminated" -ForegroundColor Green
    }
}

function memhogs {
    param([int]$Count = 10)
    
    if ($IsWindows) {
        Get-Process | 
            Sort-Object WorkingSet -Descending |
            Select-Object -First $Count |
            Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id |
            Format-Table -AutoSize
    } else {
        ps aux --sort=-%mem | Select-Object -First $Count
    }
}

function cpuhogs {
    param([int]$Count = 10)
    
    if ($IsWindows) {
        Get-Process | 
            Sort-Object CPU -Descending |
            Select-Object -First $Count |
            Select-Object ProcessName, CPU, Id |
            Format-Table -AutoSize
    } else {
        ps aux --sort=-%cpu | Select-Object -First $Count
    }
}
#endregion

#region Cross-Platform File Operations
function open-with {
    param(
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$App
    )
    
    if ($IsWindows) {
        Start-Process $App -ArgumentList $File
    } elseif ($IsMacOS) {
        open -a $App $File
    } else {
        # Linux - try xdg-open
        if (Get-Command xdg-open -ErrorAction SilentlyContinue) {
            xdg-open $File
        } else {
            Write-Error "No suitable open command found"
        }
    }
}

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
#endregion

#region Windows-Specific Functions (only load on Windows)
if ($IsWindows) {
    # Windows System Shortcuts
    Set-Alias -Name explorer -Value explorer.exe
    Set-Alias -Name notepad -Value notepad.exe
    Set-Alias -Name calc -Value calc.exe
    Set-Alias -Name mspaint -Value mspaint.exe
    Set-Alias -Name taskmgr -Value taskmgr.exe
    Set-Alias -Name cmd -Value cmd.exe
    Set-Alias -Name wt -Value wt.exe

    # Control Panel Applets
    function appwiz { control appwiz.cpl }
    function inetcpl { control inetcpl.cpl }
    function ncpa { ncpa.cpl }
    function sysdm { sysdm.cpl }
    function firewall { firewall.cpl }
    function desk { control desk.cpl }
    function timedate { control timedate.cpl }
    function powercfg { control powercfg.cpl }
    function intl { control intl.cpl }
    function joy { control joy.cpl }
    function main { control main.cpl }
    function mmsys { control mmsys.cpl }
    function syskey { syskey.exe }

    # Administrative Tools
    function devmgmt { devmgmt.msc }
    function diskmgmt { diskmgmt.msc }
    function tasksched { taskschd.msc }
    function services { services.msc }
    function eventvwr { eventvwr.msc }
    function compmgmt { compmgmt.msc }
    function lusrmgr { lusrmgr.msc }
    function perfmon { perfmon.msc }
    function resmon { resmon.exe }
    function msconfig { msconfig.exe }
    function regedit { regedit.exe }
    function gpedit { gpedit.msc }
    function secpol { secpol.msc }
    function certmgr { certmgr.msc }

    # Windows-specific functions
    function reload-explorer {
        Stop-Process -Name explorer -Force
        Start-Process explorer
    }

    function create-shortcut {
        param(
            [Parameter(Mandatory)][string]$Target,
            [Parameter(Mandatory)][string]$ShortcutPath
        )
        
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $Target
        $Shortcut.Save()
        
        Write-Host "Shortcut created: $ShortcutPath" -ForegroundColor Green
    }

    function pin-to-taskbar {
        param([Parameter(Mandatory)][string]$Path)
        
        $sa = New-Object -c Shell.Application
        $pn = $sa.Namespace($(Split-Path $Path)).ParseName($(Split-Path $Path -Leaf))
        $pn.InvokeVerb('taskbarpin')
    }

    function get-product-key {
        $map = "BCDFGHJKMPQRTVWXY2346789"
        $value = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DigitalProductId[0x34..0x42]
        $productKey = ""
        
        for ($i = 24; $i -ge 0; $i--) {
            $r = 0
            for ($j = 14; $j -ge 0; $j--) {
                $r = ($r * 256) -bxor $value[$j]
                $value[$j] = [math]::Floor($r / 24)
                $r = $r % 24
            }
            $productKey = $map[$r] + $productKey
            if (($i % 5) -eq 0 -and $i -ne 0) {
                $productKey = "-" + $productKey
            }
        }
        
        $productKey
    }

    function disable-hibernation {
        Start-Process powercfg -ArgumentList "/hibernate off" -Verb RunAs
        Write-Host "Hibernation disabled" -ForegroundColor Green
    }

    function enable-dark-mode {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
        Write-Host "Dark mode enabled (logoff required)" -ForegroundColor Green
    }

    function enable-light-mode {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
        Write-Host "Light mode enabled (logoff required)" -ForegroundColor Green
    }

    # Windows Terminal
    function wt-here { wt -d . }
    function wt-admin { Start-Process wt -Verb RunAs }
    function wt-split { wt -d . ; wt -d . ; wt -d . }

    Write-Host "✓ Windows-specific utilities loaded" -ForegroundColor DarkGray
}
#endregion

#region macOS-Specific Functions (only load on macOS)
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

    function sleep-mac {
        osascript -e 'tell application "System Events" to sleep'
    }

    Write-Host "✓ macOS-specific utilities loaded" -ForegroundColor DarkGray
}
#endregion

#region Linux-Specific Functions (only load on Linux)
if ($IsLinux) {
    function apt-update {
        sudo apt update
        sudo apt upgrade -y
    }

    function dnf-update {
        sudo dnf update -y
    }

    function pacman-update {
        sudo pacman -Syu --noconfirm
    }

    function service-status {
        param([Parameter(Mandatory)][string]$Service)
        systemctl status $Service
    }

    function service-start {
        param([Parameter(Mandatory)][string]$Service)
        sudo systemctl start $Service
    }

    function service-stop {
        param([Parameter(Mandatory)][string]$Service)
        sudo systemctl stop $Service
    }

    function service-restart {
        param([Parameter(Mandatory)][string]$Service)
        sudo systemctl restart $Service
    }

    Write-Host "✓ Linux-specific utilities loaded" -ForegroundColor DarkGray
}
#endregion

#region Cross-Platform Utilities
function timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }
function today { Get-Date -Format "yyyy-MM-dd" }
function week { Get-Date -UFormat "%V" }

function weather {
    param([string]$Location = "")
    $url = if ($Location) { "wttr.in/$Location?format=v2" } else { "wttr.in/?format=v2" }
    try {
        Invoke-RestMethod -Uri $url -TimeoutSec 10
    } catch {
        Write-Error "Could not fetch weather"
    }
}

function qr {
    param([Parameter(Mandatory)][string]$Text)
    try {
        Invoke-RestMethod -Uri "qrenco.de/$Text" -TimeoutSec 5
    } catch {
        Write-Error "Could not generate QR code"
    }
}

function cheat {
    param([Parameter(Mandatory)][string]$Query)
    try {
        Invoke-RestMethod -Uri "cheat.sh/$Query" -TimeoutSec 10
    } catch {
        Write-Error "Could not fetch cheat sheet"
    }
}
#endregion

Write-Host "✓ Cross-platform system utilities loaded" -ForegroundColor Green