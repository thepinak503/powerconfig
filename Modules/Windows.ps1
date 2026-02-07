# PowerConfig Windows-Specific
# Windows utilities, shortcuts, and system functions

# Only load on Windows
if (-not ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6))) {
    return
}

#region Windows System Shortcuts
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
function sysdm { sysdm.cpl }
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
function devmode { shell:AppsFolder\Microsoft.Windows.DevHome_8wekyb3d8bbwe!App }
#endregion

#region File System
function hosts { notepad C:\Windows\System32\drivers\etc\hosts }
function desktop { Set-Location $env:USERPROFILE\Desktop }
function documents { Set-Location $env:USERPROFILE\Documents }
function downloads { Set-Location $env:USERPROFILE\Downloads }
function pictures { Set-Location $env:USERPROFILE\Pictures }
function videos { Set-Location $env:USERPROFILE\Videos }
function music { Set-Location $env:USERPROFILE\Music }
function startup { Set-Location "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" }
function programs { Set-Location "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" }
function temp { Set-Location $env:TEMP }

# Recycle Bin
function emptytrash { Clear-RecycleBin -Force }
function recycle { explorer shell:RecycleBinFolder }

# Quick access to common folders
function envvars { rundll32 sysdm.cpl,EditEnvironmentVariables }
function startupfolder { explorer "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" }
#endregion

#region Windows Functions
function emptytrash {
    <#
    .SYNOPSIS
        Empty the Recycle Bin
    #>
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin emptied" -ForegroundColor Green
}

function reload-explorer {
    <#
    .SYNOPSIS
        Restart Windows Explorer
    #>
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

function flush-dns {
    <#
    .SYNOPSIS
        Clear DNS cache
    #>
    Clear-DnsClientCache
    Write-Host "DNS cache cleared" -ForegroundColor Green
}

function open-with {
    <#
    .SYNOPSIS
        Open file with specific application
    .PARAMETER File
        File to open
    .PARAMETER App
        Application to use
    #>
    param(
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$App
    )
    
    Start-Process $App -ArgumentList $File
}

function find-process {
    <#
    .SYNOPSIS
        Find process by name and show details
    .PARAMETER Name
        Process name
    #>
    param([Parameter(Mandatory)][string]$Name)
    
    Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
        Select-Object Id, ProcessName, Path, CPU, WorkingSet |
        Format-Table -AutoSize
}

function kill-by-name {
    <#
    .SYNOPSIS
        Kill process by name
    .PARAMETER Name
        Process name to kill
    #>
    param([Parameter(Mandatory)][string]$Name)
    
    Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
        Stop-Process -Force
    
    Write-Host "Processes matching '$Name' terminated" -ForegroundColor Green
}

function create-shortcut {
    <#
    .SYNOPSIS
        Create a shortcut
    .PARAMETER Target
        Target path
    .PARAMETER ShortcutPath
        Where to create the shortcut
    #>
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
    <#
    .SYNOPSIS
        Pin application to taskbar
    .PARAMETER Path
        Path to application
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    $sa = New-Object -c Shell.Application
    $pn = $sa.Namespace($(Split-Path $Path)).ParseName($(Split-Path $Path -Leaf))
    $pn.InvokeVerb('taskbarpin')
}

function get-product-key {
    <#
    .SYNOPSIS
        Get Windows product key
    #>
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
    <#
    .SYNOPSIS
        Disable hibernation to free up disk space
    #>
    Start-Process powercfg -ArgumentList "/hibernate off" -Verb RunAs
    Write-Host "Hibernation disabled" -ForegroundColor Green
}

function enable-dark-mode {
    <#
    .SYNOPSIS
        Enable Windows dark mode
    #>
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    Write-Host "Dark mode enabled (logoff required)" -ForegroundColor Green
}

function enable-light-mode {
    <#
    .SYNOPSIS
        Enable Windows light mode
    #>
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
    Write-Host "Light mode enabled (logoff required)" -ForegroundColor Green
}
#endregion

#region PowerShell Settings
# Execution Policy
function set-executionpolicy-remote {
    <#
    .SYNOPSIS
        Set execution policy to RemoteSigned
    #>
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "Execution policy set to RemoteSigned" -ForegroundColor Green
}

# Profile Management
function edit-profile { & $env:EDITOR $PROFILE }
function new-profile { New-Item -Path $PROFILE -ItemType File -Force }
function test-profile { powershell -NoProfile -Command "Get-Command" }
#endregion

#region Windows Terminal
function wt-here { wt -d . }
function wt-admin { Start-Process wt -Verb RunAs }
function wt-split { wt -d . ; wt -d . ; wt -d . }
#endregion

#region Utilities
function timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }
function today { Get-Date -Format "yyyy-MM-dd" }
function week { Get-Date -UFormat "%V" }
function reload { . $PROFILE }

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
