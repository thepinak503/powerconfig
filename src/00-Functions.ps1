# =============================================================================
# PowerConfig - ULTIMATE FUNCTIONS
# =============================================================================

# -----------------------------------------------------------------------------
# UTILITIES
# -----------------------------------------------------------------------------
function Test-CommandExists { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

function global:mkcd {
    param([string]$dir)
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

function global:back {
    if ($OLDPWD) { Set-Location $OLDPWD }
}

function global:docs { Set-Location ([Environment]::GetFolderPath("MyDocuments")) }
function global:dtop { Set-Location ([Environment]::GetFolderPath("Desktop")) }
function global:dl { Set-Location $env:USERPROFILE\Downloads }
function global:cdp { Set-Location "$env:USERPROFILE\Documents\projects" }
function global:cdcode { Set-Location "$env:USERPROFILE\Documents\code" }
function global:cddev { Set-Location "$env:USERPROFILE\Documents\dev" }

# -----------------------------------------------------------------------------
# FILE OPERATIONS
# -----------------------------------------------------------------------------
function global:touch {
    param([string]$file)
    "" | Out-File $file -Encoding ASCII
}

function global:ff {
    param([string]$name)
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue | Select-Object FullName
}

function global:ffe {
    param([string]$ext)
    Get-ChildItem -Recurse -Filter "*.$ext*" -ErrorAction SilentlyContinue | Select-Object FullName
}

function global:backup {
    param([string]$Path, [string]$Destination)
    if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found" -ForegroundColor Red; return }
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $name = Split-Path $Path -Leaf
    $dir = Split-Path $Path -Parent
    $ext = [System.IO.Path]::GetExtension($name)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
    $dest = if ($Destination) { Join-Path $Destination "$base`_$ts$ext" } else { Join-Path $dir "$base`_$ts$ext" }
    Copy-Item -Path $Path -Destination $dest
    Write-Host "[OK] $dest" -ForegroundColor Green
    $dest
}

function global:extract {
    param([string]$Path)
    if (-not (Test-Path $Path)) { Write-Host "[ERROR] File not found" -ForegroundColor Red; return }
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    $base = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    switch ($ext) {
        ".zip" { Expand-Archive -Path $Path -DestinationPath $base -Force; Write-Host "[OK] $base" -ForegroundColor Green }
        ".tar.gz" { tar -xzf $Path -C $base; Write-Host "[OK] $base" -ForegroundColor Green }
        ".tgz" { tar -xzf $Path -C $base; Write-Host "[OK] $base" -ForegroundColor Green }
        ".7z" { 7z x $Path -o$base; Write-Host "[OK] $base" -ForegroundColor Green }
        ".rar" { unrar x $Path $base; Write-Host "[OK] $base" -ForegroundColor Green }
        default { Write-Host "[ERROR] Unknown: $ext" -ForegroundColor Red }
    }
}

function global:trash {
    param([string]$path)
    if (Test-Path $path) {
        $shell = New-Object -ComObject Shell.Application
        $item = $shell.Namespace((Split-Path $path -Parent)).ParseName((Split-Path $path -Leaf))
        $item.InvokeVerb("delete")
    }
}

# -----------------------------------------------------------------------------
# TEXT TOOLS
# -----------------------------------------------------------------------------
function global:head { param([string]$Path, [int]$n = 10) Get-Content $Path -Head $n }
function global:tail { param([string]$Path, [int]$n = 10, [switch]$f) Get-Content $Path -Tail $n -Wait:$f }
function global:cat { Get-Content $args[0] }
function global:grep { param([string]$regex, [string]$dir) if ($dir) { Get-ChildItem $dir -Recurse -File | Select-String $regex } else { $input | Select-String $regex } }
function global:sed { param([string]$file, [string]$find, [string]$replace) (Get-Content $file).Replace($find, $replace) | Set-Content $file }
function global:catn { param([string]$Path) Get-Content $Path -Head 100 | ForEach-Object { "$($_.ReadCount): $($_.Line)" } }
function global:catl { param([string]$Path, [int]$n = 20) Get-Content $Path -Tail $n }
function global:which { param([string]$name) (Get-Command $name).Source }

# -----------------------------------------------------------------------------
# SYSTEM
# -----------------------------------------------------------------------------
function global:uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    Write-Host "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m" -ForegroundColor Cyan
}

function global:sysinfo {
    if (Test-CommandExists fastfetch) { fastfetch }
    elseif (Test-CommandExists neofetch) { neofetch }
    else { Get-ComputerInfo }
}

function global:myip {
    $ipv4 = try { (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content } catch { "N/A" }
    Write-Host "IPv4: $ipv4" -ForegroundColor Cyan
}

function global:pubip { (Invoke-WebRequest http://ifconfig.me/ip).Content }

function global:flushdns {
    Clear-DnsClientCache
    Write-Host "DNS cleared" -ForegroundColor Green
}

function global:weather {
    param([string]$loc = "")
    Invoke-WebRequest -Uri "https://wttr.in/$loc" -UseBasicParsing | Select-Object -ExpandProperty Content
}

function global:df { Get-Volume }

function global:du {
    param([string]$path = ".")
    if (Test-CommandExists dust) { dust $path }
    elseif (Test-CommandExists ncdu) { ncdu $path }
    else { Get-ChildItem $path -Recurse | Measure-Object -Property Length -Sum }
}

function global:top {
    if (Test-CommandExists btop) { btop }
    elseif (Test-CommandExists htop) { htop }
    else { Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, WorkingSet }
}

# -----------------------------------------------------------------------------
# PROCESS
# -----------------------------------------------------------------------------
function global:k9 { param([string]$name) Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force }
function global:pkill { param([string]$name) Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force }
function global:pgrep { param([string]$name) Get-Process -Name $name }
function global:killport {
    param([int]$Port)
    $proc = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -First 1
    if ($proc) { Stop-Process -Id $proc -Force; Write-Host "[OK] Port $Port freed" -ForegroundColor Green }
}

# -----------------------------------------------------------------------------
# CACHE
# -----------------------------------------------------------------------------
function global:Clear-Cache {
    Write-Host "Clearing cache..." -ForegroundColor Cyan
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Cache cleared!" -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# GIT
# -----------------------------------------------------------------------------
function global:ga { git add @args }
function global:gaa { git add --all }
function global:gs { git status }
function global:gss { git status -sb }
function global:gc { param([string]$m) git commit -m $m }
function global:gca { param([string]$m) git commit --amend -m $m }
function global:gco { git checkout @args }
function global:gcb { param([string]$b) git checkout -b $b }
function global:gp { git push }
function global:gpf { git push --force-with-lease }
function global:gpl { git pull }
function global:gd { git diff }
function global:gds { git diff --staged }
function global:gb { git branch }
function global:gf { git fetch }
function global:gfa { git fetch --all }
function global:gm { git merge }
function global:gr { param([string]$target) git rebase $target }
function global:gri { param([string]$target) git rebase -i $target }
function global:gst { git stash }
function global:gstp { git stash pop }
function global:gsta { git stash apply }
function global:gstl { git stash list }
function global:gl { git log --oneline --graph --decorate -20 }
function global:glog { param([int]$n = 20) git log --oneline -$n }
function global:gcl { param([string]$url) git clone $url }
function global:gcom {
    param([string]$m = "update")
    git add -A; git commit -m $m; git push
}
function global:gcap {
    param([string]$m)
    git add -A; git commit -m $m; git push
}

# -----------------------------------------------------------------------------
# DOCKER
# -----------------------------------------------------------------------------
function global:dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function global:dpa { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function global:di { docker images }
function global:dimg { docker images }
function global:dex { param([string]$c) docker exec -it $c pwsh }
function global:dexsh { param([string]$c) docker exec -it $c sh }
function global:dlogs { param([string]$c) docker logs -f $c }
function global:dstop { docker stop @args }
function global:dstart { docker start @args }
function global:drm { docker rm @args }
function global:drmi { docker rmi @args }
function global:dprune { docker system prune -af }
function global:dclean { docker system prune -af --volumes }
function global:dbuild { param([string]$tag) docker build -t $tag . }
function global:drun { param([string]$image) docker run -it --rm $image }
function global:dtop { docker stats --no-stream }
function global:dc { docker-compose @args }
function global:dcu { docker-compose up }
function global:dcud { docker-compose up -d }
function global:dcd { docker-compose down }
function global:dcr { docker-compose restart }

# -----------------------------------------------------------------------------
# KUBERNETES
# -----------------------------------------------------------------------------
function global:kg { kubectl get @args }
function global:kga { kubectl get all }
function global:kgp { kubectl get pods }
function global:kgs { kubectl get svc }
function global:kgd { kubectl get deployments }
function global:kgn { kubectl get nodes }
function global:kns { param([string]$n) kubectl config set-context --current --namespace=$n }
function global:kctx { kubectl config current-context }
function global:kuse { param([string]$ctx) kubectl config use-context $ctx }
function global:kd { kubectl describe @args }
function global:kdp { param([string]$pod) kubectl describe pod $pod }
function global:kl { kubectl logs @args }
function global:klf { param([string]$pod) kubectl logs -f $pod }
function global:kex { kubectl exec -it @args }
function global:ka { kubectl apply -f @args }
function global:kdel { kubectl delete @args }
function global:kdf { kubectl delete -f @args }
function global:kpf { kubectl port-forward @args }
function global:krun { kubectl run @args }

# -----------------------------------------------------------------------------
# NPM
# -----------------------------------------------------------------------------
function global:npi { npm install }
function global:npid { npm install -D }
function global:npr { npm run }
function global:nrd { npm run dev }
function global:nrt { npm run test }
function global:ns { npm start }
function global:nt { npm test }
function global:nb { npm run build }

function global:y { yarn @args }
function global:yi { yarn add }
function global:yd { yarn dev }
function global:yr { yarn run }

function global:p { pnpm @args }
function global:pi { pnpm install }
function global:pad { pnpm add }
function global:pr { pnpm run }

# -----------------------------------------------------------------------------
# DEVELOPMENT
# -----------------------------------------------------------------------------
function global:serve { param([int]$port = 8080) python -m http.server $port }
function global:python { python @args }
function global:pip { pip @args }
function global:venv { param([string]$name = "venv") python -m venv $name }
function global:activate { param([string]$name = "venv") & ".\$name\Scripts\Activate.ps1" }
function global:nodejs { node @args }
function global:nodemon { nodemon @args }
function global:tsc { tsc @args }
function global:go { go @args }
function global:cargo { cargo @args }
function global:deno { deno @args }
function global:bun { bun @args }

# -----------------------------------------------------------------------------
# TERRAFORM
# -----------------------------------------------------------------------------
function global:tfi { terraform init }
function global:tfp { terraform plan }
function global:tfa { terraform apply }
function global:tfd { terraform destroy }
function global:tfr { terraform refresh }
function global:tfo { terraform output }
function global:tfv { terraform validate }

# -----------------------------------------------------------------------------
# CLOUD
# -----------------------------------------------------------------------------
function global:az { az @args }
function global:aws { aws @args }
function global:gcloud { gcloud @args }
function global:azlogin { az login }
function global:awswho { aws sts get-caller-identity }

# -----------------------------------------------------------------------------
# EDITOR
# -----------------------------------------------------------------------------
$EDITOR = if (Test-CommandExists nvim) { "nvim" }
elseif (Test-CommandExists code) { "code --wait" }
else { "notepad" }

function global:e { param([string]$file) & $EDITOR $file }
function global:ep { & $EDITOR $PROFILE }
function global:evim { & $EDITOR "$env:USERPROFILE\.vimrc" }
function global:ebash { & $EDITOR "$env:USERPROFILE\.bashrc" }
function global:egit { & $EDITOR "$env:USERPROFILE\.gitconfig" }
function global:vim { param([string]$file) & $EDITOR $file }

# -----------------------------------------------------------------------------
# WINDOWS
# -----------------------------------------------------------------------------
function global:explorer { explorer.exe }
function global:calc { calc.exe }
function global:taskmgr { taskmgr.exe }
function global:regedit { regedit.exe }
function global:hosts { notepad C:\Windows\System32\drivers\etc\hosts }
function global:reload-explorer { Stop-Process explorer -Force; Start-Process explorer }

function global:admin {
    if ($args.Count -gt 0) {
        $argList = $args -join ' '
        Start-Process wt -Verb RunAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
    } else {
        Start-Process wt -Verb RunAs
    }
}

function global:runas {
    param([string]$cmd)
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit -Command $cmd"
}

# -----------------------------------------------------------------------------
# UTILITIES
# -----------------------------------------------------------------------------
function global:genpass {
    param([int]$len = 16)
    -join ((33..126) | Get-Random -Count $len | ForEach-Object { [char]$_ })
}

function global:timer {
    param([string]$cmd)
    $sw = [diagnostics.Stopwatch]::StartNew()
    Invoke-Expression $cmd
    $sw.Stop()
    Write-Host "Time: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Cyan
}

function global:winutil {
    Invoke-RestMethod -Uri https://christitus.com/win | Invoke-Expression
}

function global:winutildev {
    Invoke-RestMethod -Uri https://christitus.com/windev | Invoke-Expression
}

# -----------------------------------------------------------------------------
# UPDATE / HELP
# -----------------------------------------------------------------------------
function global:Update-PowerConfig {
    Write-Host "Checking for updates..." -ForegroundColor Cyan
    if (Test-Path "$env:POWERCONFIG_DIR\.git") {
        git -C $env:POWERCONFIG_DIR pull
        Write-Host "Updated! Restart shell." -ForegroundColor Green
    } else {
        Write-Host "irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install/install.ps1 | iex" -ForegroundColor Yellow
    }
}

function global:Edit-Profile { & $EDITOR $PROFILE }
function global:Invoke-Profile { & $PROFILE }
function global:reload-profile { & $PROFILE }

function global:dottools {
    Write-Host "`n=== PowerConfig Tools ===" -ForegroundColor Cyan
    $tools = @("starship", "zoxide", "fastfetch", "docker", "kubectl", "nvim", "git", "node", "python", "go")
    foreach ($t in $tools) {
        if (Test-CommandExists $t) { Write-Host "[OK] $t" -ForegroundColor Green } else { Write-Host "[--] $t" -ForegroundColor Yellow }
    }
    Write-Host ""
}

function global:Show-Help {
    @"
PowerConfig ULTIMATE Help
===================
Navigation: mkcd, back, docs, dtop, dl, cdp, cdcode
Files: touch, ff, ffe, backup, extract, trash
Text: head, tail, grep, sed, cat, catn
System: uptime, sysinfo, myip, flushdns, weather
Process: pkill, pgrep, killport
Git: g, gs, ga, gc, gp, gpl, gd, gco, gb
Docker: d, dps, dpa, dex, dlogs, dbuild
K8s: k, kgp, kgs, kd, kl, kex
Dev: npi, nb, tfi, tfp, tfa
Editor: e, ep, vim
Utils: winutil, Update-PowerConfig, Show-Help
"@
}

function global:Show-PowerDocs {
    $DocsPath = Join-Path $env:POWERCONFIG_DIR "docs\index.html"
    if (Test-Path $DocsPath) {
        Start-Process $DocsPath
    } else {
        Write-Host "Docs not found. Run 'Update-PowerConfig' to get them." -ForegroundColor Yellow
    }
}