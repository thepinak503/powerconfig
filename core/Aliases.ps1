Set-Alias ..   goUp    -ErrorAction SilentlyContinue
Set-Alias ...  goUpUp  -ErrorAction SilentlyContinue
Set-Alias home goHome  -ErrorAction SilentlyContinue

function global:g  { git @args }
function global:d  { docker @args }
function global:k  { kubectl @args }
function global:tf { terraform @args }
Set-Alias h     Get-History         -ErrorAction SilentlyContinue
Set-Alias cls   Clear-Host          -ErrorAction SilentlyContinue
Set-Alias clr   Clear-Host          -ErrorAction SilentlyContinue
Set-Alias x     Exit                -ErrorAction SilentlyContinue
Set-Alias which Get-Command         -ErrorAction SilentlyContinue
function global:env { Get-ChildItem Env: }
Set-Alias reload Invoke-ProfileReload -ErrorAction SilentlyContinue
Set-Alias trim  Out-String.Trim     -ErrorAction SilentlyContinue

function global:goUp   { Set-Location .. }
function global:goUpUp { Set-Location ../.. }
function global:goHome { Set-Location ~ }

function global:l  { if ($Cmds.eza) { eza -la --group-directories-first --icons @args } else { Get-ChildItem @args } }
function global:ll { if ($Cmds.eza) { eza -l --group-directories-first --icons @args } else { Get-ChildItem | Format-Table Name, Length, LastWriteTime } }
function global:la { if ($Cmds.eza) { eza -la --group-directories-first --icons @args } else { Get-ChildItem -Force } }
function global:lt { if ($Cmds.eza) { eza --tree --level=2 --icons @args } else { Get-ChildItem -Recurse -Depth 2 | Where-Object { $_.PSIsContainer } } }
function global:l1 { if ($Cmds.eza) { eza -1 @args } else { Get-ChildItem | Select-Object -ExpandProperty Name } }

function global:cat { if ($Cmds.bat) { bat --style=header,grid @args } else { Get-Content @args } }
function global:grep { if ($Cmds.rg) { rg @args } else { Select-String @args } }
function global:find { if ($Cmds.fd) { fd @args } else { Get-ChildItem -Recurse -Filter "*$($args[0])*" } }
function global:du   { if ($Cmds.dust) { dust @args } else { Get-ChildItem -Recurse | Measure-Object -Property Length -Sum } }
function global:df   { if ($Cmds.duf) { duf @args } else { Get-Volume } }
function global:top  { if ($Cmds.btop) { btop } elseif ($Cmds.procs) { procs } else { Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 } }
function global:help { Get-Help @args }
function global:man  { Get-Help @args }

function global:gst  { git status -sb }
function global:gs   { git status }
function global:ga   { git add @args }
function global:gaa  { git add --all }
function global:gap  { git add -p }
function global:gc   { param($m) if ($m) { git commit -m $m } else { git commit } }
function global:gcm  { param($m) git commit -m $m }
function global:gco  { git checkout @args }
function global:gcb  { param($b) git checkout -b $b }
function global:gd   { git diff @args }
function global:gds  { git diff --staged }
function global:gf   { git fetch }
function global:gfa  { git fetch --all }
function global:gp   { git push }
function global:gpf  { git push --force-with-lease }
function global:gpl  { git pull }
function global:gplr { git pull --rebase }
function global:gb   { git branch }
function global:gba  { git branch -a }
function global:gbd  { param($b) git branch -d $b }
function global:gl   { git log --oneline --graph --decorate -20 }
function global:gla  { git log --oneline --graph --decorate --all }
function global:gstash { git stash }
function global:gstp { git stash pop }
function global:gsta { git stash apply }
function global:gstl { git stash list }
function global:gm   { git merge @args }
function global:gr   { git rebase @args }
function global:gri  { param($t) git rebase -i $t }
function global:gcp  { git cherry-pick @args }
function global:gcl  { param($u) git clone $u }
function global:gcl1 { param($u) git clone --depth=1 $u }
function global:gsh  { git show @args }
function global:gbl  { param($f) git blame $f }
function global:grs  { param($c) git reset --soft $c }
function global:grh  { param($c) git reset --hard $c }
function global:gcom { git add -A; git commit -m "update" }
function global:gcap { param($m) git add -A; git commit -m $m; git push }
function global:gg   { git log --all --graph --oneline }
function global:gt   { git tag @args }

function global:dps  { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function global:dpa  { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function global:di   { docker images }
function global:dex  { param($c) docker exec -it $c powershell }
function global:dexsh { param($c) docker exec -it $c sh }
function global:dbash { param($c) docker exec -it $c bash }
function global:dlogs { param($c) docker logs -f $c }
function global:dstop { docker stop @args }
function global:dstart { docker start @args }
function global:drm  { docker rm @args }
function global:drmi { docker rmi @args }
function global:dprune { docker system prune -af }
function global:dclean { docker system prune -af --volumes }
function global:dbuild { param($t) docker build -t $t . }
function global:drun  { param($i) docker run -it --rm $i }
function global:dtop  { docker stats --no-stream }
function global:dc    { docker-compose @args }
function global:dcu   { docker-compose up @args }
function global:dcud  { docker-compose up -d }
function global:dcd   { docker-compose down }
function global:dcr   { docker-compose restart }
function global:dcl   { docker-compose logs -f }
function global:dcb   { docker-compose build }

function global:kg   { kubectl get @args }
function global:kga  { kubectl get all }
function global:kgp  { kubectl get pods }
function global:kgs  { kubectl get svc }
function global:kgd  { kubectl get deployments }
function global:kgn  { kubectl get nodes }
function global:kgns { kubectl get namespaces }
function global:kgaa { kubectl get all --all-namespaces }
function global:kd   { kubectl describe @args }
function global:kdp  { param($p) kubectl describe pod $p }
function global:kl   { kubectl logs @args }
function global:klf  { param($p) kubectl logs -f $p }
function global:kex  { kubectl exec -it @args }
function global:ka   { kubectl apply -f @args }
function global:kdel { kubectl delete @args }
function global:kpf  { kubectl port-forward @args }
function global:kctx { kubectl config current-context }
function global:kuse { param($c) kubectl config use-context $c }
function global:kns  { param($n) kubectl config set-context --current --namespace=$n }
function global:ktop { kubectl top @args }
function global:krun { param($i) kubectl run $i --image=$i --restart=Never }

function global:tfi { terraform init }
function global:tfp { terraform plan }
function global:tfa { terraform apply }
function global:tfd { terraform destroy }
function global:tfv { terraform validate }
function global:tfo { terraform output }
function global:tfs { terraform show }

function global:ni  { npm install @args }
function global:nid { npm install -D @args }
function global:nr  { npm run @args }
function global:nrd { npm run dev }
function global:nrb { npm run build }
function global:nrt { npm run test }
function global:ns  { npm start }
function global:nt  { npm test }
function global:nx  { npx @args }

function global:yi  { yarn add @args }
function global:yr  { yarn run @args }
function global:yb  { yarn build }
function global:yd  { yarn dev }

function global:pi  { pnpm install @args }
function global:pad { pnpm add @args }
function global:pr  { pnpm run @args }

function global:py  { python @args }
function global:py3 { python3 @args }
function global:pip { pip @args }

function global:e   { param($f) & $EDITOR $f }
function global:ep  { & $EDITOR $PROFILE }
function global:eg  { & $EDITOR $env:HOME\.gitconfig }
function global:ev  { & $EDITOR $env:HOME\.vimrc }

function global:wsl { wsl @args }
function global:wt  { wt @args }
function global:wtadm { Start-Process wt -Verb RunAs }
