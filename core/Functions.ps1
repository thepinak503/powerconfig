function global:Test-CommandExists { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

function global:mkcd {
    param([string]$dir)
    if (-not $dir) { Write-Host "Usage: mkcd <dir>"; return }
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

function global:touch {
    param([string]$file)
    if ($file) {
        "" | Out-File $file -Encoding ASCII
    }
}

function global:docs { Set-Location ([Environment]::GetFolderPath('MyDocuments')) }
function global:desktop { Set-Location ([Environment]::GetFolderPath('Desktop')) }
function global:dl   { Set-Location "$env:USERPROFILE\Downloads" }
function global:cdp  { Set-Location "$env:USERPROFILE\Documents\projects" }
function global:tmp  { Set-Location $env:TEMP }
function global:dots { Set-Location $env:POWERCONFIG_DIR }

function global:back {
    if ($global:OLDPWD) { Set-Location $global:OLDPWD }
}

function global:head { param($Path, $n = 10) Get-Content $Path -Head $n }
function global:tail { param($Path, $n = 10) Get-Content $Path -Tail $n }
function global:which { param($cmd) (Get-Command $cmd -ErrorAction SilentlyContinue).Source }
function global:uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    Write-Host "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m" -ForegroundColor Cyan
}

function global:sysinfo {
    if ($Cmds.fastfetch) { fastfetch @args }
    else { Get-ComputerInfo }
}

function global:myip {
    try { (Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content } catch { 'N/A' }
}

function global:localip {
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne '127.0.0.1' } | Select-Object -ExpandProperty IPAddress
}

function global:flushdns {
    Clear-DnsClientCache
    Write-Host "DNS cache cleared" -ForegroundColor Green
}

function global:weather {
    param($loc = '')
    $url = if ($loc) { "https://wttr.in/$loc" } else { 'https://wttr.in' }
    try { Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content } catch { Write-Host "Could not fetch weather" -ForegroundColor Red }
}

function global:k9 { param($name) Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force }
function global:pkill { param($name) Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force }
function global:pgrep { param($name) Get-Process -Name $name -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, CPU, WorkingSet }

function global:killport {
    param([int]$Port)
    $proc = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
    if ($proc) { Stop-Process -Id $proc -Force; Write-Host "Port $Port freed" -ForegroundColor Green }
}

function global:genpass {
    param([int]$len = 16)
    -join ((33..126) | Get-Random -Count $len | ForEach-Object { [char]$_ })
}

function global:uuid {
    [guid]::NewGuid().ToString()
}

function global:timer {
    param([string]$cmd)
    $sw = [Diagnostics.Stopwatch]::StartNew()
    Invoke-Expression $cmd
    $sw.Stop()
    Write-Host "Time: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Cyan
}

function global:extract {
    param([string]$Path)
    if (-not (Test-Path $Path)) { Write-Host "File not found: $Path" -ForegroundColor Red; return }
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    $base = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    switch ($ext) {
        '.zip'    { Expand-Archive -Path $Path -DestinationPath $base -Force }
        '.tar.gz' { tar -xzf $Path -C $base }
        '.tgz'    { tar -xzf $Path -C $base }
        '.7z'     { 7z x $Path "-o$base" }
        '.rar'    { unrar x $Path $base }
        default   { Write-Host "Unknown format: $ext" -ForegroundColor Red }
    }
    Write-Host "Extracted to: $base" -ForegroundColor Green
}

function global:backup {
    param([string]$Path, [string]$Destination)
    if (-not (Test-Path $Path)) { Write-Host "File not found" -ForegroundColor Red; return }
    $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
    $name = Split-Path $Path -Leaf
    $ext = [System.IO.Path]::GetExtension($name)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
    $dest = if ($Destination) { Join-Path $Destination "$base`_$ts$ext" } else { Join-Path (Split-Path $Path -Parent) "$base`_$ts$ext" }
    Copy-Item -Path $Path -Destination $dest
    Write-Host "Backup: $dest" -ForegroundColor Green
    $dest
}

function global:serve {
    param([int]$port = 8080)
    python -m http.server $port
}

function global:venv {
    param([string]$name = 'venv')
    python -m venv $name
}

function global:activate {
    param([string]$name = 'venv')
    & ".\$name\Scripts\Activate.ps1"
}

function global:admin {
    if ($args.Count -gt 0) {
        Start-Process wt -Verb RunAs -ArgumentList "pwsh -NoExit -Command $($args -join ' ')"
    } else {
        Start-Process wt -Verb RunAs
    }
}

function global:reload-explorer {
    Stop-Process -Name explorer -Force; Start-Process explorer
}

function global:Edit-Profile { & $EDITOR $PROFILE }
function global:Invoke-ProfileReload { . $PROFILE; Write-Host "Profile reloaded" -ForegroundColor Green }
function global:Show-PowerConfigHelp {
    @"
PowerConfig Help
================
Navigation: mkcd, back, docs, dtop, dl, cdp, tmp, dots
System:     sysinfo, uptime, myip, localip, flushdns, weather
Files:      touch, extract, backup, head, tail, grep, find
Process:    pgrep, pkill, killport, k9
Git:        gs, ga, gaa, gc, gcm, gco, gcb, gd, gp, gpl, gl, gstash
Docker:     dps, dpa, dex, dlogs, dbuild, dprune, dc
K8s:        kg, kgp, kgs, kd, kl, kex, kpf
Terraform:  tfi, tfp, tfa, tfd
Dev:        ni, nrd, serve, venv, activate
Utils:      genpass, uuid, timer, dottools, dotphase, dotinstall
Win:        admin, hosts, flushdns, reload-explorer, winutil
Editor:     e, ep, ev, eg
"@
}

function global:Show-Help { Show-PowerConfigHelp }
function global:reload-profile { Invoke-ProfileReload }
