# =============================================================================
# PowerConfig MegaFunctions - Inspired by thepinak503/dotfiles
# =============================================================================

# -----------------------------------------------------------------------------
# NAVIGATION FUNCTIONS
# -----------------------------------------------------------------------------

function mkcd {
    param([string]$Path)
    if (-not $Path) { Write-Host "Usage: mkcd <directory>"; return }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}
Set-Alias -Name mkcd -Value mkcd

function back {
    if ($OLDPWD) { Set-Location $OLDPWD }
}
Set-Alias -Name back -Value back

function cddesk { Set-Location $HOME\Desktop }
function cddl { Set-Location $HOME\Downloads }
function cddocs { Set-Location $HOME\Documents }
function cdDEV { Set-Location "$HOME\Documents\dev" }
Set-Alias -Name cddesk -Value cddesk
Set-Alias -Name cddl -Value cddl
Set-Alias -Name cddocs -Value cddocs
Set-Alias -Name cddev -Value cdDEV

# -----------------------------------------------------------------------------
# FILE OPERATIONS
# -----------------------------------------------------------------------------

function backup {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        [string]$Destination
    )
    if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red; return }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $name = Split-Path $Path -Leaf
    $ext = [System.IO.Path]::GetExtension($name)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
    
    if ($Destination) {
        $backupPath = Join-Path $Destination "$base`_$timestamp$ext"
    } else {
        $dir = Split-Path $Path -Parent
        $backupPath = Join-Path $dir "$base`_$timestamp$ext"
    }
    
    Copy-Item -Path $Path -Destination $backupPath
    Write-Host "[OK] Backed up to: $backupPath" -ForegroundColor Green
    return $backupPath
}
Set-Alias -Name backup -Value backup
Set-Alias -Name bak -Value backup

function extract {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )
    if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red; return }
    
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    
    switch -Regex ($extension) {
        '\.zip$' {
            Expand-Archive -Path $Path -DestinationPath $baseName -Force
            Write-Host "[OK] Extracted: $baseName" -ForegroundColor Green
        }
        '\.tar\.gz$' - '\.tgz$' {
            $outDir = $baseName -replace '\.tar\.gz$', ''
            tar -xzf $Path -C $outDir
            Write-Host "[OK] Extracted: $outDir" -ForegroundColor Green
        }
        '\.tar$' {
            $outDir = $baseName
            tar -xf $Path -C $outDir
            Write-Host "[OK] Extracted: $outDir" -ForegroundColor Green
        }
        '\.7z$' {
            7z x $Path -o$baseName
            Write-Host "[OK] Extracted: $baseName" -ForegroundColor Green
        }
        Default {
            Write-Host "[ERROR] Unknown format: $extension" -ForegroundColor Red
        }
    }
}
Set-Alias -Name extract -Value extract
Set-Alias -Name unpack -Value extract

function swap {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$File1,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$File2
    )
    if (-not (Test-Path $File1)) { Write-Host "[ERROR] File not found: $File1" -ForegroundColor Red; return }
    if (-not (Test-Path $File2)) { Write-Host "[ERROR] File not found: $File2" -ForegroundColor Red; return }
    
    $temp = "$env:TEMP\swap_temp_$(Get-Random)"
    Move-Item -Path $File1 -Destination $temp
    Move-Item -Path $File2 -Destination $File1
    Move-Item -Path $temp -Destination $File2
    
    Write-Host "[OK] Swapped: $File1 <-> $File2" -ForegroundColor Green
}
Set-Alias -Name swap -Value swap

# -----------------------------------------------------------------------------
# SHELL MANAGEMENT
# -----------------------------------------------------------------------------

function reload {
    $PROFILE = if ($PSVersionTable.PSEdition -eq "Core") {
        "$HOME\Documents\PowerShell\profile.ps1"
    } else {
        "$HOME\Documents\WindowsPowerShell\profile.ps1"
    }
    . $PROFILE
    Write-Host "[OK] Profile reloaded!" -ForegroundColor Green
}
Set-Alias -Name reload -Value reload

function touch {
    param([string]$Path)
    if (-not $Path) { Write-Host "Usage: touch "; return }
    $dir = Split-Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $Path)) {
        New-Item -ItemType File -Path $Path | Out-Null
    } else {
        (Get-Item $Path).LastWriteTime = Get-Date
    }
}
Set-Alias -Name touch -Value touch

# -----------------------------------------------------------------------------
# GIT SHORTCUTS (Lazy workflow)
# -----------------------------------------------------------------------------

function gcap {
    param([string]$Message)
    if (-not $Message) { $Message = "checkpoint: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
    git add -A
    git commit -m $Message
    git push
}
Set-Alias -Name gcap -Value gcap

function gcom {
    git add -A
    git commit -m "update"
}
Set-Alias -Name gcom -Value gcom

# -----------------------------------------------------------------------------
# SYSTEM INFO
# -----------------------------------------------------------------------------

function sysinfo {
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        fastfetch
    } else {
        Write-Host "Install fastfetch for system info" -ForegroundColor Yellow
    }
}
Set-Alias -Name sysinfo -Value sysinfo
Set-Alias -Name neofetch -Value sysinfo

# -----------------------------------------------------------------------------
# NETWORK
# -----------------------------------------------------------------------------

function myip {
    $ipv4 = try { (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content } catch { "N/A" }
    $ipv6 = try { (Invoke-WebRequest -Uri "https://api64.ipify.org" -UseBasicParsing).Content } catch { "N/A" }
    Write-Host "IPv4: $ipv4" -ForegroundColor Cyan
    Write-Host "IPv6: $ipv6" -ForegroundColor Cyan
}
Set-Alias -Name myip -Value myip

function weather {
    param([string]$Location = "")
    $url = if ($Location) { "https://wttr.in/$Location" } else { "https://wttr.in" }
    try {
        Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
    } catch {
        Write-Host "[ERROR] Could not fetch weather" -ForegroundColor Red
    }
}
Set-Alias -Name weather -Value weather

# -----------------------------------------------------------------------------
# DOCKER SHORTCUTS
# -----------------------------------------------------------------------------

function dps { docker ps }
function dpa { docker ps -a }
function dimg { docker images }
function dlogs { docker logs -f }
function dex { docker exec -it }
Set-Alias -Name dps -Value dps
Set-Alias -Name dpa -Value dpa
Set-Alias -Name dimg -Value dimg
Set-Alias -Name dlogs -Value dlogs
Set-Alias -Name dex -Value dex

# -----------------------------------------------------------------------------
# KUBERNETES SHORTCUTS
# -----------------------------------------------------------------------------

function k { kubectl }
function kgp { kubectl get pods }
function kgs { kubectl get svc }
function kgd { kubectl get deployments }
function kga { kubectl get all }
function kd { kubectl describe }
function kl { kubectl logs -f }
function kex { kubectl exec -it }
function ka { kubectl apply -f }
function kr { kubectl delete }
Set-Alias -Name k -Value k
Set-Alias -Name kgp -Value kgp
Set-Alias -Name kgs -Value kgs
Set-Alias -Name kgd -Value kgd
Set-Alias -Name kga -Value kga
Set-Alias -Name kd -Value kd
Set-Alias -Name kl -Value kl
Set-Alias -Name kex -Value kex
Set-Alias -Name ka -Value ka
Set-Alias -Name kr -Value kr

# -----------------------------------------------------------------------------
# QUICK EDITORS
# -----------------------------------------------------------------------------

function evim { nvim $HOME/.vimrc }
function ebash { nvim $HOME/.bashrc }
function eprofile { nvim $PROFILE }
function egit { nvim $HOME/.gitconfig }
Set-Alias -Name evim -Value evim
Set-Alias -Name ebash -Value ebash
Set-Alias -Name eprofile -Value eprofile
Set-Alias -Name egit -Value egit

# -----------------------------------------------------------------------------
# UTILITIES
# -----------------------------------------------------------------------------

function genpass {
    param([int]$Length = 16)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}
Set-Alias -Name genpass -Value genpass

function killport {
    param([int]$Port)
    $proc = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
    if ($proc) {
        Stop-Process -Id $proc -Force
        Write-Host "[OK] Killed process on port $Port" -ForegroundColor Green
    } else {
        Write-Host "[INFO] No process on port $Port" -ForegroundColor Yellow
    }
}
Set-Alias -Name killport -Value killport

function timer {
    param([string]$Command)
    $sw = [diagnostics.Stopwatch]::StartNew()
    Invoke-Expression $Command
    $sw.Stop()
    Write-Host "Time: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Cyan
}
Set-Alias -Name timer -Value timer

function trash {
    param([string]$Path)
    if (-not $Path) { Write-Host "Usage: trash "; return }
    if (Test-Path $Path) {
        $shell = New-Object -ComObject Shell.Application
        $item = $shell.Namespace(0).ParseName($Path)
        $item.InvokeVerb("delete")
    }
}
Set-Alias -Name trash -Value trash

# Mega Functions loaded!
Write-Host "[OK] MegaFunctions loaded" -ForegroundColor Green