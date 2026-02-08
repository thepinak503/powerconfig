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

#region Git
Set-Alias -Name g -Value git

function ga { git add @args }
function gaa { git add --all @args }
function gb { git branch @args }
function gba { git branch -a @args }
function gc { git commit @args }
function gcm { git commit -m @args }
function gcam { git commit -am @args }
function gco { git checkout @args }
function gcb { git checkout -b @args }
function gd { git diff @args }
function gds { git diff --staged @args }
function gf { git fetch @args }
function gl { git log --oneline --graph --decorate @args }
function glog { git log --oneline --graph --decorate --all @args }
function gm { git merge @args }
function gp { git push @args }
function gpf { git push --force-with-lease @args }
function gpl { git pull @args }
function gr { git remote -v @args }
function grb { git rebase @args }
function grbi { git rebase -i @args }
function gs { git status -sb @args }
function gst { git stash @args }
function gstp { git stash pop @args }
function gsta { git stash apply @args }
function gstl { git stash list @args }

function gcl { git clone $args }
function gcp { git cherry-pick $args }
function grm { git rm $args }
function grmc { git rm --cached $args }
function gundo { git reset HEAD~1 --mixed }
function gclean { git clean -fd }
function gpristine { git reset --hard; git clean -dfx }
function gwip { git add -A; git commit -m "--wip-- [skip ci]" }
function gunwip { git log -n 1 | Select-String "--wip--" && git reset HEAD~1 }

function lazyg {
    param([string]$Message)
    if (-not $Message) { Write-Host "Usage: lazyg <message>" -ForegroundColor Red; return }
    git add .; git commit -m "$Message"; git push
}

function gcurrent { git branch --show-current }
function gdefault { git symbolic-ref refs/remotes/origin/HEAD --short | ForEach-Object { $_ -replace "origin/", "" } }
function gstats { git shortlog -sn }

# Git Branch Management
function gbd { git branch -d $args }
function gbD { git branch -D $args }
function gbm { git branch -m $args }
#endregion

#region Docker
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value docker-compose
Set-Alias -Name dps -Value Get-DockerContainers
Set-Alias -Name dpa -Value Get-DockerAllContainers
Set-Alias -Name di -Value Get-DockerImages
Set-Alias -Name dl -Value Get-DockerLogs

function Get-DockerContainers { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function Get-DockerAllContainers { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function Get-DockerImages { docker images }
function Get-DockerLogs { param([string]$Container) docker logs -f $Container }
function dex { param([string]$Container) docker exec -it $Container sh }
function dr { param([string]$Image) docker run -it --rm $Image }
function dri { param([string]$Image) docker run -it $Image }
function dprune { docker system prune -af }
function dprunev { docker volume prune -f }
function dstats { docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" }

# Docker Compose
function dcu { docker-compose up $args }
function dcud { docker-compose up -d $args }
function dcd { docker-compose down $args }
function dcdv { docker-compose down -v $args }
function dcr { docker-compose restart $args }
function dcb { docker-compose build $args }
function dcl { docker-compose logs -f $args }
function dce { docker-compose exec $args }
function dcs { docker-compose stop $args }
function dcstart { docker-compose start $args }
#endregion

#region Kubernetes
Set-Alias -Name k -Value kubectl
Set-Alias -Name kg -Value Get-Kubectl
Set-Alias -Name kd -Value Describe-Kubectl
Set-Alias -Name kl -Value Logs-Kubectl

function Get-Kubectl { kubectl get $args }
function Describe-Kubectl { kubectl describe $args }
function Logs-Kubectl { kubectl logs -f $args }
function kex { kubectl exec -it $args }
function kgp { kubectl get pods $args }
function kgs { kubectl get svc $args }
function kgd { kubectl get deployment $args }
function kgn { kubectl get nodes $args }
function kgns { kubectl get namespace $args }
function kga { kubectl get all $args }
function kgaa { kubectl get all --all-namespaces $args }
function kdp { kubectl describe pod $args }
function kds { kubectl describe svc $args }
function kdd { kubectl describe deployment $args }
function kdn { kubectl describe node $args }
function kpf { kubectl port-forward $args }
function ktop { kubectl top $args }
function ka { kubectl apply $args }
function kdel { kubectl delete $args }

# Helm
function h { helm $args }
function hin { helm install $args }
function hup { helm upgrade $args }
function hdel { helm delete $args }
function hls { helm list $args }
function hsearch { helm search hub $args }
#endregion

#region Python
Set-Alias -Name py -Value python
Set-Alias -Name py3 -Value python3
Set-Alias -Name pip -Value pip3

function pipi { pip install $args }
function pipu { pip install --upgrade $args }
function pipun { pip uninstall $args }
function pipl { pip list $args }
function pipf { pip freeze $args }
function pipo { pip list --outdated $args }

function venv { python -m venv $args }
function venva { .\venv\Scripts\Activate.ps1 }
function venvd { deactivate }

# Poetry
function po { poetry $args }
function poa { poetry add $args }
function pou { poetry update $args }
function poi { poetry install $args }
function por { poetry run $args }
function pos { poetry shell $args }
function pob { poetry build $args }
function popub { poetry publish $args }
#endregion

#region Node.js
function nr { npm run @args }
function ns { npm start @args }
function nb { npm run build @args }
function nt { npm test @args }
function ni { npm install @args }
function nid { npm install --save-dev @args }
function nig { npm install -g @args }
function nu { npm uninstall @args }
function nup { npm update @args }
function nls { npm list --depth=0 @args }
function nout { npm outdated @args }
function nci { npm ci @args }

# Yarn
function yr { yarn run $args }
function ys { yarn start $args }
function yb { yarn build $args }
function yt { yarn test $args }
function ya { yarn add $args }
function yad { yarn add --dev $args }
function yrm { yarn remove $args }
function yu { yarn upgrade $args }

# PNPM
function pn { pnpm $args }
function pni { pnpm install $args }
function pnr { pnpm run $args }
function pns { pnpm start $args }
#endregion

#region Rust
function c { cargo $args }
function cb { cargo build $args }
function cbr { cargo build --release $args }
function cr { cargo run $args }
function ct { cargo test $args }
function cc { cargo check $args }
function cf { cargo fmt $args }
function clippy { cargo clippy $args }
function cdoc { cargo doc --open $args }
function cnew { cargo new $args }
function cinit { cargo init $args }
function cpub { cargo publish $args }
#endregion

#region Go
function gob { go build $args }
function gor { go run $args }
function got { go test $args }
function goi { go install $args }
function gog { go get $args }
#endregion

#region Cross-Platform Utilities
# Platform detection
$IsWindows = $false
$IsMacOS = $false
$IsLinux = $false

if ($PSVersionTable.PSVersion.Major -lt 6) {
    $IsWindows = $true
} else {
    $IsWindows = $IsWindows
    $IsMacOS = $IsMacOS
    $IsLinux = $IsLinux
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
        sudo & $env:EDITOR "/etc/hosts"
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

#region Terraform
function tf { terraform $args }
function tfa { terraform apply $args }
function tfauto { terraform apply -auto-approve $args }
function tfd { terraform destroy $args }
function tff { terraform fmt $args }
function tfi { terraform init $args }
function tfp { terraform plan $args }
function tfv { terraform validate $args }
function tfw { terraform workspace $args }
#endregion

#region AWS
function awsls { aws s3 ls $args }
function awscp { aws s3 cp $args }
function awssync { aws s3 sync $args }
function awswho { aws sts get-caller-identity $args }
#endregion
