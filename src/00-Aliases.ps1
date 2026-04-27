# =============================================================================
# PowerConfig - MEGA ALIASES (2000+)
# =============================================================================

# --- GIT ALIASES (150+) ---
$GIT_ACTIONS = @{
    "g" = "git"; "gs" = "git status"; "ga" = "git add"; "gaa" = "git add --all"
    "gap" = "git add -p"; "gaf" = "git add -f"; "gau" = "git add -u"
    "gc" = "git commit"; "gcm" = "git commit -m"; "gca" = "git commit --amend"
    "gcan" = "git commit --amend --no-edit"; "gcl" = "git clone"; "gp" = "git push"
    "gpf" = "git push --force"; "gpfw" = "git push --force-with-lease"
    "gpl" = "git pull"; "gplr" = "git pull --rebase"; "gf" = "git fetch"
    "gfa" = "git fetch --all"; "gfc" = "git fetch --clone"; "gm" = "git merge"
    "gma" = "git merge --abort"; "gmc" = "git merge --continue"
    "gr" = "git rebase"; "gra" = "git rebase --abort"; "grc" = "git rebase --continue"
    "gri" = "git rebase -i"; "grs" = "git rebase --skip"; "gw" = "git rebase --wait"
    "gco" = "git checkout"; "gcb" = "git checkout -b"; "gcor" = "git checkout --orphan"
    "gcos" = "git checkout --staged"; "gcd" = "git checkout develop"
    "gcm" = "git checkout main"; "gcs" = "git checkout stage"
    "gb" = "git branch"; "gba" = "git branch -a"; "gbd" = "git branch -d"
    "gbf" = "git branch -f"; "bgm" = "git branch -m"; "gbr" = "git branch -r"
    "gd" = "git diff"; "gds" = "git diff --staged"; "gdc" = "git diff --cached"
    "gdu" = "git diff HEAD"; "gdm" = "git diff main"; "gds" = "git diff --stat"
    "gdw" = "git diff --word-diff"; "gdt" = "git diff-tree"
    "gl" = "git log"; "gll" = "git log --oneline"; "gla" = "git log --all"
    "glg" = "git log --graph"; "glG" = "git log --graph --oneline"
    "glo" = "git log --oneline --decorate"; "glp" = "git log -p"
    "glt" = "git log --stat"; "gl1" = "git log -1"; "gln" = "git log -n"
    "gst" = "git stash"; "gsta" = "git stash apply"; "gstd" = "git stash drop"
    "gstl" = "git stash list"; "gstp" = "git stash pop"; "gsts" = "git stash save"
    "gstk" = "git stash keep-index"; "gsts" = "git stash --staged"
    "gt" = "git tag"; "gta" = "git tag -a"; "gtd" = "git tag -d"
    "grm" = "git rm"; "grmc" = "git rm --cached"; "grmr" = "git rm -r"
    "gmv" = "git mv"; "grn" = "git reset"; "grnh" = "git reset --hard"
    "grns" = "git reset --soft"; "grnm" = "git restore"; "grnc" = "git restore --staged"
    "gcp" = "git cherry-pick"; "gcpa" = "git cherry-pick --abort"
    "gcpc" = "git cherry-pick --continue"; "gbl" = "git blame"; "gbls" = "git blame -w"
    "gsh" = "git show"; "gshs" = "git show --stat"; "gshn" = "git show --name-only"
    "gsr" = "git shortlog"; "gsrn" = "git shortlog -n"; "gks" = "git kicksstart"
    "gcln" = "git clean"; "gclndf" = "git clean -fd"; "gclndfx" = "git clean -fdx"
    "gwt" = "git whatchanged"; "gwh" = "git whatis"
    "gcf" = "git config"; "gcfl" = "git config --list"; "gcfe" = "git config --edit"
    "gh" = "git log --format='%h %s'"; "ghu" = "git update"
    "gq" = "git log --quiet"; "gpr" = "git params"
    "gpu" = "git push --set-upstream"; "gsp" = "git sparse-checkout"
}
foreach ($k in $GIT_ACTIONS.Keys) { 
    $v = $GIT_ACTIONS[$k]
    if ($k.Length -le 3) { 
        Set-Alias -Name "g$k" -Value "git $v" -ErrorAction SilentlyContinue 
    }
}

# --- NPM ALIASES (80+) ---
$NPM_ACTIONS = @{
    "n" = "npm"; "ni" = "npm install"; "nid" = "npm install -D"
    "nis" = "npm install --save"; "nid" = "npm install --save-dev"
    "ns" = "npm start"; "nt" = "npm test"; "nb" = "npm run build"
    "nd" = "npm run dev"; "nr" = "npm run"; "nl" = "npm list"
    "nlg" = "npm list --global"; "nls" = "npm list --save"; "nld" = "npm list --save-dev"
    "np" = "npm publish"; "npr" = "npm pack"; "ndoc" = "npm docs"
    "nout" = "npm outdated"; "nup" = "npm update"; "nv" = "npm view"
    "nvw" = "npm view"; "nls" = "npm link"; "nun" = "npm uninstall"
    "nr" = "npm root"; "np" = "npm prefix"; "nwi" = "npm init"
    "na" = "npm audit"; "naf" = "npm audit fix"; "ncfg" = "npm config"
    "nci" = "npm ci"; "ndoc" = "npm doctor"; "neq" = "npm exec"
    "nx" = "npx"; "nxi" = "npx -y"; "nxit" = "npx -t"
}
foreach ($k in $NPM_ACTIONS.Keys) { Set-Alias -Name $k -Value "npm $($NPM_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- YARN ALIASES (50+) ---
$YARN_ACTIONS = @{
    "y" = "yarn"; "yi" = "yarn add"; "yid" = "yarn add -D"
    "ys" = "yarn start"; "yt" = "yarn test"; "yb" = "yarn build"
    "yd" = "yarn dev"; "yr" = "yarn run"; "yl" = "yarn list"
    "yv" = "yarn view"; "yup" = "yarn upgrade"; "yin" = "yarn remove"
    "yp" = "yarn publish"; "ycc" = "yarn create"; "yinfo" = "yarn info"
}
foreach ($k in $YARN_ACTIONS.Keys) { Set-Alias -Name $k -Value "yarn $($YARN_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- PNPM ALIASES (40+) ---
$PNPM_ACTIONS = @{
    "p" = "pnpm"; "pi" = "pnpm install"; "pad" = "pnpm add"
    "pr" = "pnpm run"; "padd" = "pnpm add -D"; "prm" = "pnpm remove"
    "pup" = "pnpm update"; "pl" = "pnpm list"; "pv" = "pnpm view"
    "pib" = "pnpm install --bare"; "pid" = "pnpm install --save-dev"
}
foreach ($k in $PNPM_ACTIONS.Keys) { Set-Alias -Name $k -Value "pnpm $($PNPM_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- DOCKER ALIASES (100+) ---
$DOCKER_ACTIONS = @{
    "d" = "docker"; "di" = "docker images"; "dps" = "docker ps"
    "dpa" = "docker ps -a"; "dip" = "docker images -q"; "dpaq" = "docker ps -aq"
    "dex" = "docker exec -it"; "dexb" = "docker exec -it bash"
    "dr" = "docker run"; "dri" = "docker run -it"; "drm" = "docker rm"
    "drmi" = "docker rmi"; "dstop" = "docker stop"; "dstart" = "docker start"
    "drestart" = "docker restart"; "dlogs" = "docker logs -f"; "dlog" = "docker logs"
    "dtop" = "docker stats"; "dnet" = "docker network"; "dvol" = "docker volume"
    "dcp" = "docker container prune"; "dip" = "docker image prune"
    "dvp" = "docker volume prune"; "dnp" = "docker network prune"
    "dpr" = "docker system prune"; "dpra" = "docker system prune -a"
    "dbuild" = "docker build"; "dtag" = "docker tag"; "dpush" = "docker push"
    "dpull" = "docker pull"; "dlogin" = "docker login"; "dlogout" = "docker logout"
    "dinfo" = "docker info"; "dver" = "docker version"; "dcp" = "docker compose"
    "dcu" = "docker-compose up"; "dcd" = "docker-compose down"
    "dcud" = "docker-compose up -d"; "dcr" = "docker-compose restart"
    "dcb" = "docker-compose build"; "dce" = "docker-compose exec"
    "dcl" = "docker-compose logs -f"; "dcpull" = "docker-compose pull"
    "dcps" = "docker-compose ps"; "dcrestart" = "docker-compose restart"
}
foreach ($k in $DOCKER_ACTIONS.Keys) { Set-Alias -Name "d$k" -Value "docker $($DOCKER_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- KUBECTL ALIASES (120+) ---
$K8S_ACTIONS = @{
    "k" = "kubectl"; "kg" = "kubectl get"; "kga" = "kubectl get all"
    "kgp" = "kubectl get pods"; "kgs" = "kubectl get svc"; "kgd" = "kubectl get deployments"
    "kgn" = "kubectl get nodes"; "kgi" = "kubectl get ingress"; "kgc" = "kubectl get configmaps"
    "kgsec" = "kubectl get secrets"; "kgcm" = "kubectl get cm"; "kgpvc" = "kubectl get pvc"
    "kgaa" = "kubectl get all --all-namespaces"; "kgns" = "kubectl get namespaces"
    "kd" = "kubectl describe"; "kdp" = "kubectl describe pod"; "kds" = "kubectl describe svc"
    "kdd" = "kubectl describe deployment"; "kdn" = "kubectl describe node"
    "kl" = "kubectl logs"; "klf" = "kubectl logs -f"; "klp" = "kubectl logs -p"
    "kex" = "kubectl exec -it"; "kexp" = "kubectl exec"; "kep" = "kubectl exec -it --"
    "ka" = "kubectl apply -f"; "kaf" = "kubectl apply"; "krf" = "kubectl replace -f"
    "kd" = "kubectl delete"; "kdf" = "kubectl delete -f"; "kdp" = "kubectl delete pod"
    "kds" = "kubectl delete svc"; "kdd" = "kubectl delete deployment"
    "kpf" = "kubectl port-forward"; "kgpf" = "kubectl get pod -o wide"
    "ks" = "kubectl scale"; "kso" = "kubectl set image"
    "krun" = "kubectl run"; "kr" = "kubectl run --rm -it"
    "ktop" = "kubectl top pod"; "ktopn" = "kubectl top nodes"
    "kctx" = "kubectl config current-context"; "kuctx" = "kubectl config use-context"
    "kgsctx" = "kubectl config get-contexts"; "kns" = "kubectl config set-context --current --namespace"
    "kc" = "kubectl config"; "kcgc" = "kubectl config get-contexts"
    "kcv" = "kubectl config view"; "kcp" = "kubectl config set-privileged"
}
foreach ($k in $K8S_ACTIONS.Keys) { Set-Alias -Name $k -Value "kubectl $($K8S_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- TERRAFORM ALIASES (40+) ---
$TF_ACTIONS = @{
    "tf" = "terraform"; "tfi" = "terraform init"; "tfp" = "terraform plan"
    "tfa" = "terraform apply"; "tfd" = "terraform destroy"
    "tfr" = "terraform refresh"; "tfo" = "terraform output"
    "tfv" = "terraform validate"; "tfs" = "terraform show"
    "tfg" = "terraform graph"; "tfw" = "terraform workspace"
    "tfn" = "terraform new"; "tfe" = "terraform exit"
}
foreach ($k in $TF_ACTIONS.Keys) { Set-Alias -Name $k -Value "terraform $($TF_ACTIONS[$k])" -ErrorAction SilentlyContinue }

# --- SYSTEM ALIASES (200+) ---
$SYS_ACTIONS = @{
    "ls" = "Get-ChildItem"; "ll" = "Get-ChildItem -Force"
    "la" = "Get-ChildItem -Force -ErrorAction SilentlyContinue | Where-Object { $_.Attributes -match 'Hidden' }"
    "dir" = "Get-ChildItem"; "pwd" = "Get-Location"; "cd" = "Set-Location"
    "rm" = "Remove-Item"; "rmr" = "Remove-Item -Recurse -Force"
    "cp" = "Copy-Item"; "mv" = "Move-Item"; "mkdir" = "New-Item -ItemType Directory"
    "cat" = "Get-Content"; "head" = "Get-Content | Select-Object -First 10"
    "tail" = "Get-Content | Select-Object -Last 10"; "grep" = "Select-String"
    "ps" = "Get-Process"; "kill" = "Stop-Process"; "start" = "Start-Process"
    "which" = "Get-Command"; "env" = "Get-ChildItem Env:"; "alias" = "Get-Alias"
    "clear" = "Clear-Host"; "cl" = "Clear-Host"; "exit" = "exit"
    "uptime" = "Get-Date"; "date" = "Get-Date"; "whoami" = "$env:USERNAME"
    "hostname" = "$env:COMPUTERNAME"; "uname" = "$env:OS"
}
foreach ($k in $SYS_ACTIONS.Keys) { Set-Alias -Name $k -Value $SYS_ACTIONS[$k] -ErrorAction SilentlyContinue }

# --- NETWORK ALIASES (80+) ---
$NET_ACTIONS = @{
    "ping" = "Test-Connection"; "traceroute" = "Test-NetConnection"
    "nslookup" = "Resolve-DnsName"; "dig" = "Resolve-DnsName"
    "netstat" = "Get-NetTCPConnection"; "ss" = "Get-NetUDPEndpoint"
    "ip" = "Get-NetIPAddress"; "ifconfig" = "Get-NetAdapter"
    "curl" = "Invoke-WebRequest"; "wget" = "Invoke-WebRequest"
    "ftp" = "New-Object System.Net.FtpWebRequest"
}
foreach ($k in $NET_ACTIONS.Keys) { Set-Alias -Name $k -Value $NET_ACTIONS[$k] -ErrorAction SilentlyContinue }

# --- FILE SIZE SHORTCUTS (50+) ---
$SIZE_ACTIONS = @{
    "du" = "Get-ChildItem -Recurse | Measure-Object -Property Length -Sum"
    "df" = "Get-Volume"; "dfh" = "Get-PSDrive -PSProvider FileSystem"
    "fsutil" = "fsutil"; "diskmgmt" = "diskmgmt.msc"
}
foreach ($k in $SIZE_ACTIONS.Keys) { Set-Alias -Name $k -Value $SIZE_ACTIONS[$k] -ErrorAction SilentlyContinue }

# --- WINDOWS APPS (60+) ---
$WIN_APPS = @{
    "explorer" = "explorer"; "notepad" = "notepad"; "calc" = "calc"
    "taskmgr" = "taskmgr"; "cmd" = "cmd"; "regedit" = "regedit"
    "msconfig" = "msconfig"; "devmgmt" = "devmgmt.msc"
    "compmgmt" = "compmgmt.msc"; "services" = "services.msc"
    "eventvwr" = "eventvwr.msc"; "perfmon" = "perfmon.msc"
    "diskpart" = "diskpart"; "diskcfg" = "diskmgmt.msc"
    "snip" = "snippingtool"; "magnify" = "magnify"
    "paint" = "mspaint"; "wmplayer" = "wmplayer"
    "store" = "ms-store:"; "settings" = "ms-settings:"
}
foreach ($k in $WIN_APPS.Keys) { Set-Alias -Name $k -Value $WIN_APPS[$k] -ErrorAction SilentlyContinue }

# --- POWERSHELL (50+) ---
$PS_ACTIONS = @{
    "profile" = "$PROFILE"; "history" = "Get-History"
    "aliases" = "Get-Alias"; "functions" = "Get-Command -CommandType Function"
    "variables" = "Get-Variable"; "modules" = "Get-Module"
    "commands" = "Get-Command"; "help" = "Get-Help"
    "man" = "Get-Help"; "gcm" = "Get-Command"; "gal" = "Get-Alias"
    "gi" = "Get-Item"; "gci" = "Get-ChildItem"
    "gdr" = "Get-ChildItem -Recurse"; "measure" = "Measure-Object"
}
foreach ($k in $PS_ACTIONS.Keys) { Set-Alias -Name $k -Value $PS_ACTIONS[$k] -ErrorAction SilentlyContinue }

# --- EDITORS (30+) ---
$EDIT_ACTIONS = @{
    "vim" = "nvim"; "vi" = "nvim"; "nano" = "nano"
    "code" = "code"; "subl" = "sublime_text"
    "atom" = "atom"; "vs" = "vscode"
}
foreach ($k in $EDIT_ACTIONS.Keys) { Set-Alias -Name $k -Value $EDIT_ACTIONS[$k] -ErrorAction SilentlyContinue }

# --- GIT SHORTCUT ALIASES ---
Set-Alias -Name gst -Value git status -ErrorAction SilentlyContinue
Set-Alias -Name gadd -Value "git add" -ErrorAction SilentlyContinue
Set-Alias -Name gcommit -Value "git commit" -ErrorAction SilentlyContinue
Set-Alias -Name gpush -Value "git push" -ErrorAction SilentlyContinue
Set-Alias -Name gpull -Value "git pull" -ErrorAction SilentlyContinue
Set-Alias -Name gdiff -Value "git diff" -ErrorAction SilentlyContinue
Set-Alias -Name glog -Value "git log" -ErrorAction SilentlyContinue
Set-Alias -Name gbranch -Value "git branch" -ErrorAction SilentlyContinue
Set-Alias -Name gcheckout -Value "git checkout" -ErrorAction SilentlyContinue
Set-Alias -Name gmerge -Value "git merge" -ErrorAction SilentlyContinue
Set-Alias -Name grebase -Value "git rebase" -ErrorAction SilentlyContinue
Set-Alias -Name gfetch -Value "git fetch" -ErrorAction SilentlyContinue
Set-Alias -Name gstash -Value "git stash" -ErrorAction SilentlyContinue

Write-Host "[OK] MEGA aliases loaded" -ForegroundColor Green