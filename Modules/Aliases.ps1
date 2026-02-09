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
Set-Alias -Name cls -Value Clear-Host
Set-Alias -Name q -Value Exit
#endregion

#region System


function df { Get-Volume }
function ps { Get-Process }
function top { Get-Process }
function env { Get-ChildItem Env: }
#endregion

#region Git
Set-Alias -Name g -Value git
function ga { git add $args }
function gaa { git add --all $args }
function gb { git branch $args }
function gba { git branch -a $args }
function gc { git commit $args }
function gcm { git commit -m $args }
function gcam { git commit -am $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gd { git diff $args }
function gds { git diff --staged $args }
function gf { git fetch $args }
function gl { git log --oneline --graph --decorate $args }
function glog { git log --oneline --graph --decorate --all $args }
function gm { git merge $args }
function gp { git push $args }
function gpf { git push --force-with-lease $args }
function gpl { git pull $args }
function gr { git remote -v $args }
function grb { git rebase $args }
function grbi { git rebase -i $args }
function gs { git status -sb $args }
function gst { git stash $args }
function gstp { git stash pop $args }
function gsta { git stash apply $args }
function gstl { git stash list $args }

function gcl { git clone $args }
function gcp { git cherry-pick $args }
function grm { git rm $args }
function grmc { git rm --cached $args }
function gundo { git reset HEAD~1 --mixed }
function gclean { git clean -fd }
function gpristine { git reset --hard; git clean -dfx }
function gwip { git add -A; git commit -m "--wip-- [skip ci]" }
function gunwip { git log -n 1 | Select-String "--wip--" && git reset HEAD~1 }



function gcurrent { git branch --show-current }
function gdefault { git symbolic-ref refs/remotes/origin/HEAD --short | ForEach-Object { $_ -replace "origin/", "" } }
function gstats { git shortlog -sn }

# Git Branch Management
function gbd { git branch -d $args }
function gbD { git branch -D $args }
function gbm { git branch -m $args }
#endregion

#region Docker
function d { docker $args }
function dc { docker-compose $args }
function dps { Get-DockerContainers }
function dpa { Get-DockerAllContainers }
function di { Get-DockerImages }
function dl { Get-DockerLogs }

function Get-DockerContainers { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function Get-DockerAllContainers { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function Get-DockerImages { docker images }
function Get-DockerLogs { param([string]$Container = "") docker logs -f $Container }
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
function k { kubectl $args }
function kg { Get-Kubectl }
function kd { Describe-Kubectl }
function kl { Logs-Kubectl }

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
function nr { npm run $args }
function ns { npm start $args }
function nb { npm run build $args }
function nt { npm test $args }
function ni { npm install $args }
function nid { npm install --save-dev $args }
function nig { npm install -g $args }
function nu { npm uninstall $args }
function nup { npm update $args }
function nls { npm list --depth=0 $args }
function nout { npm outdated $args }
function nci { npm ci $args }

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

#region Windows Utilities
if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
    Set-Alias -Name explorer -Value explorer.exe
    Set-Alias -Name notepad -Value notepad.exe
    Set-Alias -Name calc -Value calc.exe
    Set-Alias -Name taskmgr -Value taskmgr.exe
    Set-Alias -Name mspaint -Value mspaint.exe
    
    function hosts { notepad C:\Windows\System32\drivers\etc\hosts }
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
    
    function emptytrash { Clear-RecycleBin -Force }
    function recycle { explorer shell:RecycleBinFolder }
}
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
