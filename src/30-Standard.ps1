# PowerConfig Standard - UNIX-like Utilities & Tools

function global:head {
    param([string]$Path, [int]$n = 10) 
    Get-Content $Path -Head $n 
}

function global:tail {
    param([string]$Path, [int]$n = 10, [switch]$f) 
    Get-Content $Path -Tail $n -Wait:$f 
}

function global:grep {
    param([string]$Regex) 
    $input | Select-String $Regex 
}

function global:sed {
    param([string]$File, [string]$Find, [string]$Replace) 
    (Get-Content $File).Replace($Find, $Replace) | Set-Content $File 
}

function global:which {
    param([string]$Cmd) 
    (Get-Command $Cmd).Source 
}

function global:uptime { 
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    Write-Host "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m" -ForegroundColor Cyan
}

function global:winutil { 
    Invoke-RestMethod -Uri https://christitus.com/win | Invoke-Expression 
}

function global:winutildev { 
    Invoke-RestMethod -Uri https://christitus.com/windev | Invoke-Expression 
}

function global:New-MkDirectory { 
    param([string]$Path) 
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path 
}

function global:Set-TouchFile { 
    param([string]$Path) 
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } 
    else { New-Item -ItemType File -Path $Path -Force | Out-Null } 
}