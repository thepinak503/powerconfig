# PowerConfig Standard - UNIX-like Utilities & Tools

# Ported from Chris Titus Tech
function head { param($Path, $n = 10) Get-Content $Path -Head $n }
function tail { param($Path, $n = 10, [switch]$f) Get-Content $Path -Tail $n -Wait:$f }
function grep { param($Regex) $input | Select-String $Regex }
function sed { param($File, $Find, $Replace) (Get-Content $File).Replace("$Find", "$Replace") | Set-Content $File }
function which { param($Cmd) (Get-Command $Cmd).Definition }
function uptime { 
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    Write-Host "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m" -ForegroundColor Cyan
}

# WinUtil Shortcut
function winutil { iwr -useb https://christitus.com/win | iex }
function winutildev { iwr -useb https://christitus.com/windev | iex }


# Core PowerConfig Tools (Standardized)
function New-MkDirectory { 
    param([string]$Path) 
    New-Item -ItemType Directory -Path $Path -Force | Out-Null; Set-Location $Path 
}
function Set-TouchFile { 
    param([string]$Path) 
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } 
    else { New-Item -ItemType File -Path $Path -Force | Out-Null } 
}
