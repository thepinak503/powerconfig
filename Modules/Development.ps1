# PowerConfig Development Tools
# Python, Node.js, Rust, Go, Docker, Kubernetes, Terraform

#region Platform Detection
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $script:IsWindows = $true
} else {
    $script:IsWindows = $IsWindows
    $script:IsMacOS = $IsMacOS
    $script:IsLinux = $IsLinux
}
#endregion

#region Python
# Cross-platform Python aliases
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    Set-Alias -Name py -Value python3
    Set-Alias -Name py3 -Value python3
    Set-Alias -Name pip -Value pip3
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    Set-Alias -Name py -Value python
    Set-Alias -Name py3 -Value python
    Set-Alias -Name pip -Value pip
}

function pipi { pip install $args }
function pipu { pip install --upgrade $args }
function pipun { pip uninstall $args }
function pipl { pip list $args }
function pipf { pip freeze $args }
function pipo { pip list --outdated $args }
function pipc { pip check $args }

function venv { 
    param([string]$Name = "venv")
    python -m venv $Name 
}

function venva { 
    param([string]$Name = "venv")
    
    if ($IsWindows) {
        & ".\$Name\Scripts\Activate.ps1"
    } else {
        & ".\$Name/bin/activate"
    }
}

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
function pock { poetry check $args }
function poshow { poetry show $args }
function pol { poetry lock $args }

# Conda
function ca { conda activate $args }
function cd { conda deactivate }
function ci { conda install $args }
function cu { conda update $args }
function cl { conda list $args }
function ce { conda env $args }
function cel { conda env list }
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
function pnr { pnpm run $args }
function pns { pnpm start $args }
function pnb { pnpm build $args }
function pni { pnpm install $args }
function pnid { pnpm install --save-dev $args }

# NVM (Cross-platform)
if ($IsWindows) {
    function nvm { nvm-windows $args }
    function nvml { nvm list }
    function nvmi { nvm install $args }
    function nvmu { nvm use $args }
    function nvmuse { nvm use $args }
    function nvminstall { nvm install $args }
    function nvmcurrent { nvm current }
} else {
    # NVM for Unix-like systems
    function nvm { nvm $args }
    function nvml { nvm list }
    function nvmi { nvm install $args }
    function nvmu { nvm use $args }
    function nvmuse { nvm use $args }
    function nvminstall { nvm install $args }
    function nvmcurrent { nvm current }
}
#endregion

#region Rust
function c { cargo $args }
function cb { cargo build $args }
function cbr { cargo build --release $args }
function cr { cargo run $args }
function ct { cargo test $args }
function cc { cargo check $args }
function cf { cargo fmt $args }
function cl { cargo clippy $args }
function cdoc { cargo doc --open $args }
function cnew { cargo new $args }
function cinit { cargo init $args }
function cpub { cargo publish $args }
function csearch { cargo search $args }
function ctree { cargo tree $args }
function cinstall { cargo install $args }
function cuninstall { cargo uninstall $args }
function cwatch { cargo watch -x run $args }
function cbench { cargo bench $args }
function cfix { cargo fix $args }
function cupdate { cargo update $args }

# Rustup
function rup { rustup update $args }
function rul { rustup toolchain list $args }
function rui { rustup toolchain install $args }
function ruu { rustup self update $args }
#endregion

#region Go
function gob { go build $args }
function gor { go run $args }
function got { go test $args }
function goi { go install $args }
function gog { go get $args }
function gom { go mod $args }
function gomt { go mod tidy $args }
function gomv { go mod vendor $args }
function gof { go fmt $args }
function gov { go vet $args }
function goc { go clean $args }
function gobld { go build -ldflags="-s -w" $args }
#endregion

#region Java
function mvn { mvn $args }
function mvnc { mvn clean $args }
function mvnci { mvn clean install $args }
function mvni { mvn install $args }
function mvnp { mvn package $args }
function mvnt { mvn test $args }
function mvnq { mvn dependency:tree $args }

function gr { gradle $args }
function grb { gradle build $args }
function grt { gradle test $args }
function grc { gradle clean $args }
function grcb { gradle clean build $args }
function grr { gradle run $args }
#endregion

#region Ruby
function rb { ruby $args }
function rbi { bundle install $args }
function rbe { bundle exec $args }
function rbu { bundle update $args }
function rbg { gem $args }
function rbginstall { gem install $args }
function rbguninstall { gem uninstall $args }
#endregion

#region Docker
Set-Alias -Name d -Value docker

# Check for docker-compose vs docker compose
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    Set-Alias -Name dc -Value docker-compose
    $composeCmd = "docker-compose"
} elseif (Get-Command docker -ErrorAction SilentlyContinue) {
    # Use docker compose (newer syntax)
    function dc { docker compose $args }
    $composeCmd = "docker compose"
} else {
    Write-Warning "Docker not found"
}

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

# Docker Compose (cross-platform)
function dcu { & $composeCmd up $args }
function dcud { & $composeCmd up -d $args }
function dcd { & $composeCmd down $args }
function dcdv { & $composeCmd down -v $args }
function dcr { & $composeCmd restart $args }
function dcb { & $composeCmd build $args }
function dcl { & $composeCmd logs -f $args }
function dce { & $composeCmd exec $args }
function dcs { & $composeCmd stop $args }
function dcstart { & $composeCmd start $args }
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
function krun { kubectl run $args }
function kscale { kubectl scale $args }

# Helm
function h { helm $args }
function hin { helm install $args }
function hup { helm upgrade $args }
function hdel { helm delete $args }
function hls { helm list $args }
function hsearch { helm search hub $args }
function hrepo { helm repo $args }
function hstatus { helm status $args }
#endregion

#region Terraform
function tf { terraform $args }
function tfa { terraform apply $args }
function tfauto { terraform apply -auto-approve $args }
function tfc { terraform console $args }
function tfd { terraform destroy $args }
function tff { terraform fmt $args }
function tfi { terraform init $args }
function tfiu { terraform init -upgrade $args }
function tfo { terraform output $args }
function tfp { terraform plan $args }
function tfrefresh { terraform refresh $args }
function tfs { terraform show $args }
function tfstate { terraform state $args }
function tfst { terraform state list $args }
function tfsv { terraform state mv $args }
function tfrm { terraform state rm $args }
function tfimp { terraform import $args }
function tfv { terraform validate $args }
function tfver { terraform version }
function tfw { terraform workspace $args }
function tfwl { terraform workspace list }
function tfws { terraform workspace select $args }
function tfwn { terraform workspace new $args }
function tfwd { terraform workspace delete $args }
function tfget { terraform get $args }
function tfgraph { terraform graph $args }
#endregion

#region Ansible
function an { ansible $args }
function anp { ansible-playbook $args }
function ang { ansible-galaxy $args }
function anv { ansible-vault $args }
function andoc { ansible-doc $args }
function aninv { ansible-inventory $args }
#endregion

#region AWS
function awsls { aws s3 ls $args }
function awscp { aws s3 cp $args }
function awssync { aws s3 sync $args }
function awsmv { aws s3 mv $args }
function awsrn { aws s3 rm $args }
function awswho { aws sts get-caller-identity $args }
function awsconf { aws configure $args }
function awslist { aws configure list $args }
#endregion

#region Azure
function azl { az login $args }
function azg { az group $args }
function azgn { az group create --name $args }
function azls { az account list $args }
function azs { az account set --subscription $args }
function azsub { az account show $args }
function azvm { az vm $args }
function azaks { az aks $args }
#endregion

#region GCP
function gcloud { gcloud $args }
function gcauth { gcloud auth login $args }
function gcconfig { gcloud config $args }
function gcproj { gcloud projects $args }
function gccompute { gcloud compute $args }
function gck8s { gcloud container $args }
#endregion

#region Vagrant
function vup { vagrant up $args }
function vdown { vagrant halt $args }
function vdestroy { vagrant destroy $args }
function vssh { vagrant ssh $args }
function vstat { vagrant status $args }
function vreload { vagrant reload $args }
function vsuspend { vagrant suspend $args }
function vresume { vagrant resume $args }
function vprov { vagrant provision $args }
#endregion

#region VirtualBox (Cross-platform)
if (Get-Command VBoxManage -ErrorAction SilentlyContinue) {
    function vbls { VBoxManage list vms }
    function vbrun { VBoxManage startvm $args }
    function vbstop { VBoxManage controlvm $args poweroff }
    function vbpause { VBoxManage controlvm $args pause }
    function vbresume { VBoxManage controlvm $args resume }
    
    Write-Host "✓ VirtualBox utilities loaded" -ForegroundColor DarkGray
} else {
    Write-Warning "VirtualBox not found"
}
#endregion
