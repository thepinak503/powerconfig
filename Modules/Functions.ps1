# PowerConfig Functions
# Comprehensive PowerShell utility functions

#region File & Directory Operations
function mkcd {
    <#
    .SYNOPSIS
        Create a directory and change into it
    .PARAMETER Path
        Directory path to create
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function touch {
    <#
    .SYNOPSIS
        Create a new file or update timestamp of existing file
    .PARAMETER Path
        File path
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }
}

function backup {
    <#
    .SYNOPSIS
        Backup a file with timestamp
    .PARAMETER Path
        File to backup
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "$Path.bak.$timestamp"
    
    Copy-Item -Path $Path -Destination $backupPath
    Write-Host "Backed up: $Path → $backupPath" -ForegroundColor Green
}

function extract {
    <#
    .SYNOPSIS
        Extract any archive format
    .PARAMETER Path
        Archive file to extract
    .PARAMETER Destination
        Destination directory (optional)
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Destination = "."
    )
    
    if (-not (Test-Path $Path)) {
        Write-Error "Archive not found: $Path"
        return
    }
    
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($ext) {
        '.zip' { Expand-Archive -Path $Path -DestinationPath $Destination }
        '.tar' { tar -xf $Path -C $Destination }
        '.gz' { tar -xzf $Path -C $Destination }
        '.tgz' { tar -xzf $Path -C $Destination }
        '.bz2' { tar -xjf $Path -C $Destination }
        '.xz' { tar -xJf $Path -C $Destination }
        '.7z' { 
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $Path -o$Destination
            } else {
                Write-Error "7z not found. Install with: scoop install 7zip"
            }
        }
        '.rar' {
            if (Get-Command unrar -ErrorAction SilentlyContinue) {
                unrar x $Path $Destination
            } else {
                Write-Error "unrar not found"
            }
        }
        default { Write-Error "Unknown archive format: $ext" }
    }
}

function compress {
    <#
    .SYNOPSIS
        Create an archive from files
    .PARAMETER Path
        Archive file path
    .PARAMETER Items
        Items to include
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$Items
    )
    
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($ext) {
        '.zip' { Compress-Archive -Path $Items -DestinationPath $Path }
        '.tar' { tar -cf $Path $Items }
        '.gz' { tar -czf $Path $Items }
        '.tgz' { tar -czf $Path $Items }
        '.bz2' { tar -cjf $Path $Items }
        default { Write-Error "Unknown archive format: $ext" }
    }
}

function size {
    <#
    .SYNOPSIS
        Get size of files or directories
    .PARAMETER Path
        Path to check
    #>
    param([Parameter(Mandatory)][string]$Path = ".")
    
    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }
    
    $item = Get-Item $Path
    if ($item.PSIsContainer) {
        $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
    } else {
        $size = $item.Length
    }
    
    switch ($size) {
        { $_ -gt 1GB } { "{0:N2} GB" -f ($_ / 1GB); break }
        { $_ -gt 1MB } { "{0:N2} MB" -f ($_ / 1MB); break }
        { $_ -gt 1KB } { "{0:N2} KB" -f ($_ / 1KB); break }
        default { "{0} B" -f $_ }
    }
}

function emptytrash {
    <#
    .SYNOPSIS
        Empty the Recycle Bin
    #>
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        Clear-RecycleBin -Force
        Write-Host "Recycle Bin emptied" -ForegroundColor Green
    } else {
        Write-Host "Not supported on this platform" -ForegroundColor Yellow
    }
}
#endregion

#region Search & Find
function ftext {
    <#
    .SYNOPSIS
        Search for text in files
    .PARAMETER Pattern
        Search pattern
    .PARAMETER Path
        Search path (default: current directory)
    #>
    param(
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Path = "."
    )
    
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg -i --color=always $Pattern $Path
    } else {
        Get-ChildItem $Path -Recurse -File | 
            Select-String -Pattern $Pattern | 
            Format-Table -Property Filename, LineNumber, Line -AutoSize
    }
}

function ff {
    <#
    .SYNOPSIS
        Find files by name
    .PARAMETER Name
        File name pattern
    .PARAMETER Path
        Search path
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Path = "."
    )
    
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd $Name $Path
    } else {
        Get-ChildItem $Path -Recurse -Filter "*$Name*" -File
    }
}

function fdir {
    <#
    .SYNOPSIS
        Find directories by name
    .PARAMETER Name
        Directory name pattern
    .PARAMETER Path
        Search path
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Path = "."
    )
    
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t d $Name $Path
    } else {
        Get-ChildItem $Path -Recurse -Filter "*$Name*" -Directory
    }
}
#endregion

#region Network
function myip {
    <#
    .SYNOPSIS
        Display internal and external IP addresses
    #>
    Write-Host "Internal IPs:" -ForegroundColor Cyan
    Get-NetIPAddress -AddressFamily IPv4 | 
        Where-Object { $_.IPAddress -ne "127.0.0.1" } |
        Select-Object InterfaceAlias, IPAddress |
        Format-Table
    
    Write-Host "External IP:" -ForegroundColor Cyan
    try {
        $external = Invoke-RestMethod -Uri "https://ifconfig.me" -TimeoutSec 5
        Write-Host "  $external" -ForegroundColor Green
    } catch {
        Write-Host "  Could not retrieve" -ForegroundColor Red
    }
}

function serve {
    <#
    .SYNOPSIS
        Start a simple HTTP server
    .PARAMETER Port
        Port number (default: 8080)
    .PARAMETER Path
        Directory to serve (default: current)
    #>
    param(
        [int]$Port = 8080,
        [string]$Path = "."
    )
    
    Write-Host "Serving $Path on http://localhost:$Port" -ForegroundColor Green
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port --directory $Path
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server $Port --directory $Path
    } elseif (Get-Command node -ErrorAction SilentlyContinue) {
        npx serve -p $Port $Path
    } else {
        Write-Error "No suitable server found (python, node)"
    }
}

function ports {
    <#
    .SYNOPSIS
        List listening ports
    #>
    Get-NetTCPConnection -State Listen | 
        Select-Object LocalAddress, LocalPort, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} |
        Format-Table -AutoSize
}

function flushdns {
    <#
    .SYNOPSIS
        Clear DNS cache
    #>
    Clear-DnsClientCache
    Write-Host "DNS cache cleared" -ForegroundColor Green
}

function weather {
    <#
    .SYNOPSIS
        Display weather information
    .PARAMETER Location
        Location (optional)
    #>
    param([string]$Location = "")
    
    try {
        $url = if ($Location) { "wttr.in/$Location?format=v2" } else { "wttr.in/?format=v2" }
        Invoke-RestMethod -Uri $url -TimeoutSec 10
    } catch {
        Write-Error "Could not fetch weather"
    }
}
#endregion

#region Git
function g { git @args }
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
function gcl { git clone @args }
function gcp { git cherry-pick @args }
function grm { git rm @args }
function grmc { git rm --cached @args }
function gundo { git reset HEAD~1 --mixed }
function gclean { git clean -fd }
function gpristine { git reset --hard; git clean -dfx }
function gwip { git add -A; git commit -m "--wip-- skip ci" }
function gunwip { git log -n 1 | Select-String "--wip--" && git reset HEAD~1 }
function lazyg { 
    param([string]$Message) 
    if (-not $Message) { 
        Write-Host "Usage: lazyg <message>" -ForegroundColor Red; 
        return 
    } 
    git add .; git commit -m "$Message"; git push 
}
function gcurrent { git branch --show-current }
function gdefault { git symbolic-ref refs/remotes/origin/HEAD --short | ForEach-Object { $_ -replace "origin/", "" } }
function gstats { git shortlog -sn }
function gbd { git branch -d @args }
function gbD { git branch -D @args }
function gbm { git branch -m @args }
#endregion

#region Docker
function d { docker @args }
function dc { docker-compose @args }
function dps { Get-DockerContainers }
function dpa { Get-DockerAllContainers }
function di { Get-DockerImages }
function dl { Get-DockerLogs @args }
function dex { 
    param([string]$Container) 
    docker exec -it $Container sh 
}
function dr { 
    param([string]$Image) 
    docker run -it --rm $Image 
}
function dri { 
    param([string]$Image) 
    docker run -it $Image 
}
function dprune { docker system prune -af }
function dprunev { docker volume prune -f }
function dstats { docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" }
function dcu { docker-compose up @args }
function dcud { docker-compose up -d @args }
function dcd { docker-compose down @args }
function dcdv { docker-compose down -v @args }
function dcr { docker-compose restart @args }
function dcb { docker-compose build @args }
function dcl { docker-compose logs -f @args }
function dce { docker-compose exec @args }
function dcs { docker-compose stop @args }
function dcstart { docker-compose start @args }
#endregion

#region Kubernetes
function k { kubectl @args }
function kg { Get-Kubectl @args }
function kd { Describe-Kubectl @args }
function kl { Logs-Kubectl @args }
function kex { kubectl exec -it @args }
function kgp { kubectl get pods @args }
function kgs { kubectl get svc @args }
function kgd { kubectl get deployment @args }
function kgn { kubectl get nodes @args }
function kgns { kubectl get namespace @args }
function kga { kubectl get all @args }
function kgaa { kubectl get all --all-namespaces @args }
function kdp { kubectl describe pod @args }
function kds { kubectl describe svc @args }
function kdd { kubectl describe deployment @args }
function kdn { kubectl describe node @args }
function kpf { kubectl port-forward @args }
function ktop { kubectl top @args }
function ka { kubectl apply @args }
function kdel { kubectl delete @args }
function h { helm @args }
function hin { helm install @args }
function hup { helm upgrade @args }
function hdel { helm delete @args }
function hls { helm list @args }
function hsearch { helm search hub @args }
#endregion

#region Python
function py { python @args }
function py3 { python3 @args }
function pip { pip3 @args }
function pipi { pip install @args }
function pipu { pip install --upgrade @args }
function pipun { pip uninstall @args }
function pipl { pip list @args }
function pipf { pip freeze @args }
function pipo { pip list --outdated @args }
function venv { python -m venv @args }
function venva { .\venv\Scripts\Activate.ps1 }
function venvd { deactivate }
function po { poetry @args }
function poa { poetry add @args }
function pou { poetry update @args }
function poi { poetry install @args }
function por { poetry run @args }
function pos { poetry shell @args }
function pob { poetry build @args }
function popub { poetry publish @args }
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
function yr { yarn run @args }
function ys { yarn start @args }
function yb { yarn build @args }
function yt { yarn test @args }
function ya { yarn add @args }
function yad { yarn add --dev @args }
function yrm { yarn remove @args }
function yu { yarn upgrade @args }
function pn { pnpm @args }
function pni { pnpm install @args }
function pnr { pnpm run @args }
function pns { pnpm start @args }
#endregion

#region Rust
function c { cargo @args }
function cb { cargo build @args }
function cbr { cargo build --release @args }
function cr { cargo run @args }
function ct { cargo test @args }
function cc { cargo check @args }
function cf { cargo fmt @args }
function clippy { cargo clippy @args }
function cdoc { cargo doc --open @args }
function cnew { cargo new @args }
function cinit { cargo init @args }
function cpub { cargo publish @args }
function gob { go build @args }
function gor { go run @args }
function got { go test @args }
function goi { go install @args }
function gog { go get @args }
#endregion

#region Terraform
function tf { terraform @args }
function tfa { terraform apply @args }
function tfauto { terraform apply -auto-approve @args }
function tfd { terraform destroy @args }
function tff { terraform fmt @args }
function tfi { terraform init @args }
function tfp { terraform plan @args }
function tfv { terraform validate @args }
function tfw { terraform workspace @args }
#endregion

#region AWS
function awsls { aws s3 ls @args }
function awscp { aws s3 cp @args }
function awssync { aws s3 sync @args }
function awswho { aws sts get-caller-identity @args }
#endregion

#region Process Management
function psgrep {
    <#
    .SYNOPSIS
        Find process by name
    .PARAMETER Name
        Process name to search
    #>
    param([Parameter(Mandatory)][string]$Name)
    
    Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
        Select-Object Id, ProcessName, CPU, WorkingSet |
        Format-Table -AutoSize
}

function fkill {
    <#
    .SYNOPSIS
        Interactive process killer (requires fzf)
    #>
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Error "fzf not found. Install with: scoop install fzf"
        return
    }
    
    $process = Get-Process | 
        Select-Object Id, ProcessName, CPU | 
        fzf --multi --header="[kill process]" |
        ForEach-Object { ($_ -split "\s+")[0] }
    
    if ($process) {
        Stop-Process -Id $process -Force
        Write-Host "Process killed: $process" -ForegroundColor Green
    }
}

function memhogs {
    <#
    .SYNOPSIS
        Show top processes by memory usage
    .PARAMETER Count
        Number of processes (default: 10)
    #>
    param([int]$Count = 10)
    
    Get-Process | 
        Sort-Object WorkingSet -Descending |
        Select-Object -First $Count |
        Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id |
        Format-Table -AutoSize
}

function cpuhogs {
    <#
    .SYNOPSIS
        Show top processes by CPU usage
    .PARAMETER Count
        Number of processes (default: 10)
    #>
    param([int]$Count = 10)
    
    Get-Process | 
        Sort-Object CPU -Descending |
        Select-Object -First $Count |
        Select-Object ProcessName, CPU, Id |
        Format-Table -AutoSize
}
#endregion

#region Development
function lazyg {
    <#
    .SYNOPSIS
        Git add, commit, and push in one command
    .PARAMETER Message
        Commit message
    #>
    param([Parameter(Mandatory)][string]$Message)
    
    git add .
    git commit -m "$Message"
    git push
}

function mkvenv {
    <#
    .SYNOPSIS
        Create and activate Python virtual environment
    .PARAMETER Name
        Environment name (default: venv)
    #>
    param([string]$Name = "venv")
    
    python -m venv $Name
    
    if ($IsWindows) {
        & ".\$Name\Scripts\Activate.ps1"
    } else {
        & ".\$Name/bin/activate"
    }
}

function passgen {
    <#
    .SYNOPSIS
        Generate secure password
    .PARAMETER Length
        Password length (default: 16)
    .PARAMETER Count
        Number of passwords (default: 1)
    #>
    param(
        [int]$Length = 16,
        [int]$Count = 1
    )
    
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    
    for ($i = 0; $i -lt $Count; $i++) {
        -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    }
}

function json {
    <#
    .SYNOPSIS
        Format JSON (pretty print)
 .PARAMETER Input
        JSON string or file path
    #>
    param([Parameter(Mandatory, ValueFromPipeline)][string]$Input)
    
    process {
        if (Test-Path $Input) {
            Get-Content $Input | ConvertFrom-Json | ConvertTo-Json -Depth 10
        } else {
            $Input | ConvertFrom-Json | ConvertTo-Json -Depth 10
        }
    }
}

function urlencode {
    <#
    .SYNOPSIS
        URL encode a string
    .PARAMETER String
        String to encode
    #>
    param([Parameter(Mandatory)][string]$String)
    
    if ($IsWindows) {
        [System.Web.HttpUtility]::UrlEncode($String)
    } else {
        # Cross-platform URL encoding
        Add-Type -AssemblyName System.Web
        [System.Web.HttpUtility]::UrlEncode($String)
    }
}

function urldecode {
    <#
    .SYNOPSIS
        URL decode a string
    .PARAMETER String
        String to decode
    #>
    param([Parameter(Mandatory)][string]$String)
    
    if ($IsWindows) {
        [System.Web.HttpUtility]::UrlDecode($String)
    } else {
        # Cross-platform URL decoding
        Add-Type -AssemblyName System.Web
        [System.Web.HttpUtility]::UrlDecode($String)
    }
}

function docker-clean {
    <#
    .SYNOPSIS
        Clean up Docker resources
    #>
    Write-Host "Removing stopped containers..." -ForegroundColor Yellow
    docker container prune -f
    
    Write-Host "Removing unused images..." -ForegroundColor Yellow
    docker image prune -f
    
    Write-Host "Removing unused volumes..." -ForegroundColor Yellow
    docker volume prune -f
    
    Write-Host "Removing unused networks..." -ForegroundColor Yellow
    docker network prune -f
    
    Write-Host "Docker cleanup complete!" -ForegroundColor Green
}
#endregion

#region Platform Detection
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $script:IsWindows = $true
} else {
    $script:IsWindows = $IsWindows
    $script:IsMacOS = $IsMacOS
    $script:IsLinux = $IsLinux
}

function Get-HomePath {
    if ($IsWindows) {
        return $env:USERPROFILE
    } else {
        return $env:HOME
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

#region System Utilities
function sysinfo {
    <#
    .SYNOPSIS
        Display system information
    #>
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

function diskusage {
    <#
    .SYNOPSIS
        Display disk usage
    #>
    if ($IsWindows) {
        Get-Volume | 
            Where-Object { $_.DriveLetter } |
            Select-Object DriveLetter, 
                @{Name="Size(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}},
                @{Name="Used(GB)";Expression={[math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 2)}},
                @{Name="Free(GB)";Expression={[math]::Round($_.SizeRemaining / 1GB, 2)}},
                @{Name="Usage";Expression={[math]::Round((($_.Size - $_.SizeRemaining) / $_.Size) * 100, 1)}} |
            Format-Table -AutoSize
    } else {
        df -h
    }
}

function uptime {
    <#
    .SYNOPSIS
        Show system uptime
    #>
    if ($IsWindows) {
        $bootTime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        Write-Host "System uptime: $($bootTime.Days) days, $($bootTime.Hours) hours, $($bootTime.Minutes) minutes"
    } else {
        uptime
    }
}

function emptybin {
    <#
    .SYNOPSIS
        Empty Recycle Bin/Trash
    #>
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
#endregion

#region AWS
function awsls { aws s3 ls @args }
function awscp { aws s3 cp @args }
function awssync { aws s3 sync @args }
function awswho { aws sts get-caller-identity @args }
#endregion

#region Quick Access
function docs { Set-Location (Join-Path (Get-HomePath) "Documents") }
function desktop { Set-Location (Join-Path (Get-HomePath) "Desktop") }
function downloads { Set-Location (Join-Path (Get-HomePath) "Downloads") }
function home { Set-Location (Get-HomePath) }
function tmp { Set-Location (Get-TempPath) }
#endregion
