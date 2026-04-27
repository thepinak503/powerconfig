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

function back {
    if ($OLDPWD) { Set-Location $OLDPWD }
}

function cd-desk { Set-Location $HOME\Desktop }
function cd-dl { Set-Location $HOME\Downloads }
function cd-docs { Set-Location $HOME\Documents }
function cd-dev { Set-Location "$HOME\Documents\dev" }

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
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
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
    Write-Host "[OK] Backed up: $backupPath" -ForegroundColor Green
    return $backupPath
}

Set-Alias -Name bak -Value backup

function extract {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )
    if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found: $Path" -ForegroundColor Red; return }
    
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    
    switch ($extension) {
        ".zip" {
            Expand-Archive -Path $Path -DestinationPath $baseName -Force
            Write-Host "[OK] Extracted: $baseName" -ForegroundColor Green
        }
        ".tar.gz" {
            $outDir = $baseName -replace '\.tar\.gz$', ''
            tar -xzf $Path -C $outDir
            Write-Host "[OK] Extracted: $outDir" -ForegroundColor Green
        }
        ".tgz" {
            $outDir = $baseName
            tar -xzf $Path -C $outDir
            Write-Host "[OK] Extracted: $outDir" -ForegroundColor Green
        }
        ".tar" {
            $outDir = $baseName
            tar -xf $Path -C $outDir
            Write-Host "[OK] Extracted: $outDir" -ForegroundColor Green
        }
        ".7z" {
            7z x $Path -o$baseName
            Write-Host "[OK] Extracted: $baseName" -ForegroundColor Green
        }
        default {
            Write-Host "[ERROR] Unknown format: $extension" -ForegroundColor Red
        }
    }
}

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

# -----------------------------------------------------------------------------
# SHELL MANAGEMENT
# -----------------------------------------------------------------------------

function reload-profile {
    $PROFILE = if ($PSVersionTable.PSEdition -eq "Core") {
        "$HOME\Documents\PowerShell\profile.ps1"
    } else {
        "$HOME\Documents\WindowsPowerShell\profile.ps1"
    }
    . $PROFILE
    Write-Host "[OK] Profile reloaded!" -ForegroundColor Green
}

Set-Alias -Name reload -Value reload-profile

function touch-file {
    param([string]$Path)
    if (-not $Path) { Write-Host "Usage: touch-file "; return }
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

# -----------------------------------------------------------------------------
# GIT SHORTCUTS
# -----------------------------------------------------------------------------

function gcap {
    param([string]$Message)
    if (-not $Message) { $Message = "checkpoint: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" }
    git add -A
    git commit -m $Message
    git push
}

function gcom {
    git add -A
    git commit -m "update"
}

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

function weather {
    param([string]$Location = "")
    $url = if ($Location) { "https://wttr.in/$Location" } else { "https://wttr.in" }
    try {
        Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
    } catch {
        Write-Host "[ERROR] Could not fetch weather" -ForegroundColor Red
    }
}

# -----------------------------------------------------------------------------
# DOCKER SHORTCUTS
# -----------------------------------------------------------------------------

function dps { docker ps }
function dpa { docker ps -a }
function dimg { docker images }
function dlog { docker logs -f }
function dexec { docker exec -it }

# -----------------------------------------------------------------------------
# KUBERNETES SHORTCUTS
# -----------------------------------------------------------------------------

function k { kubectl }
function kgp { kubectl get pods }
function kgs { kubectl get svc }
function kgd { kubectl get deployments }
function kga { kubectl get all }
function kd { kubectl describe }
function klog { kubectl logs -f }
function kex { kubectl exec -it }
function ka { kubectl apply -f }
function kr { kubectl delete }

# -----------------------------------------------------------------------------
# QUICK EDITORS
# -----------------------------------------------------------------------------

function evim { nvim $HOME/.vimrc }
function ebash { nvim $HOME/.bashrc }
function eprofile { nvim $PROFILE }
function egit { nvim $HOME/.gitconfig }

# -----------------------------------------------------------------------------
# UTILITIES
# -----------------------------------------------------------------------------

function genpass {
    param([int]$Length = 16)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $result = -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    Write-Host $result
}

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

function timer {
    param([string]$Command)
    $sw = [diagnostics.Stopwatch]::StartNew()
    Invoke-Expression $Command
    $sw.Stop()
    Write-Host "Time: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Cyan
}

function trash {
    param([string]$Path)
    if (-not $Path) { Write-Host "Usage: trash <path>"; return }
    if (Test-Path $Path) {
        $shell = New-Object -ComObject Shell.Application
        $item = $shell.Namespace(0).ParseName($Path)
        $item.InvokeVerb("delete")
    }
}

# -----------------------------------------------------------------------------
# DOTFILES MODE SYSTEM
# -----------------------------------------------------------------------------
function chmode {
    param(
        [ValidateSet("basic", "minimal", "standard", "supreme", "ultra-nerd")]
        [string]$Mode = "standard"
    )
    $env:POWERCONFIG_MODE = $Mode
    $stateFile = "$env:USERPROFILE\.config\powerconfig-mode"
    $stateDir = Split-Path $stateFile -Parent
    if (-not (Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
    Set-Content -Path $stateFile -Value $Mode
    Write-Host "[OK] Mode set to: $Mode" -ForegroundColor Green
    Write-Host "Restart PowerShell or run 'reload' to apply" -ForegroundColor Cyan
}

# Quick directory jumping
function cdp { Set-Location "$env:USERPROFILE\Documents\projects" }
function cdcode { Set-Location "$env:USERPROFILE\Documents\code" }

# Docker full
function d { docker @args }
function dbuild { docker build -t $args[0] . }
function dclean { docker system prune -af }
function dprune { docker system prune -f }

# Git functions
function ga { git add @args }
function gs { git status }
function gc { git commit -m @args }
function gp { git push }
function gpl { git pull }
function gd { git diff }
function gco { git checkout @args }
function gb { git branch }
function gf { git fetch }
function gm { git merge }
function gr { git rebase }
function gst { git stash }
function gl { git log }

# Kubernetes full functions
function kgall { kubectl get all }
function kdelp { kubectl delete pod @args }
function kpf { kubectl port-forward @args }

# Terraform
function tf { terraform @args }
function tfi { terraform init }
function tfp { terraform plan }
function tfa { terraform apply }
function tfd { terraform destroy }

# NPM shortcuts
function npi { npm install }
function npid { npm install -D }
function nrx { npm run }
function nrt { npm run test }
function nrd { npm run dev }
function ns { npm start }
function nt { npm test }

# Search functions
function ff { Get-ChildItem -Recurse -Filter "*$args[0]*" | Select-Object FullName }
function ffr { Get-ChildItem -Recurse -File | Select-String $args[0] | Select-Object Filename, LineNumber }

Write-Host "[OK] MegaFunctions loaded" -ForegroundColor Green