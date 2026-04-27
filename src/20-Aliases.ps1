# PowerConfig MegaAliases - The Massive Alias Grid
# Programmatically generated shortcuts for every possible workflow

# region GIT GRID
$gitActions = @{
    "ga" = "add"; "gc" = "commit"; "gp" = "push"; "gl" = "pull"; 
    "gco" = "checkout"; "gb" = "branch"; "gd" = "diff"; "gs" = "status";
    "gf" = "fetch"; "gm" = "merge"; "gr" = "rebase"; "gst" = "stash"
}
foreach ($key in $gitActions.Keys) {
    $val = $gitActions[$key]
    function global:"g$key" { git $val @args }
}
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue
# endregion

# region DOCKER GRID
$dockerActions = @{
    "di" = "images"; "dp" = "ps"; "dr" = "run"; "ds" = "stop"; 
    "dl" = "start"; "dlog" = "logs"; "dexec" = "exec"; "dv" = "volume";
    "dn" = "network"; "db" = "build"; "dc" = "compose"
}
foreach ($key in $dockerActions.Keys) {
    $val = $dockerActions[$key]
    function global:"d$key" { docker $val @args }
}
Set-Alias -Name d -Value docker -ErrorAction SilentlyContinue
# endregion

# region KUBERNETES GRID
$k8sResources = @("pod", "service", "deployment", "node", "namespace", "ingress", "configmap", "secret")
foreach ($r in $k8sResources) {
    function global:"kg$($r[0])" { kubectl get $r @args }
    function global:"kd$($r[0])" { kubectl describe $r @args }
    function global:"ke$($r[0])" { kubectl edit $r @args }
}
# endregion

# region SYSTEM NAVIGATION GRID
$locations = @("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos", "projects", "code")
foreach ($l in $locations) {
    $short = $l[0..2] -join ""
    function global:"cd$($short.ToLower())" { Set-Location (Get-ChildItem $l -ErrorAction SilentlyContinue).FullName }
}
# endregion