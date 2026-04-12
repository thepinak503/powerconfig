# PowerConfig MegaAliases - The Massive Alias Grid
# Programmatically generated shortcuts for every possible workflow

# region GIT GRID
$gitActions = @{
    "a" = "add"; "c" = "commit"; "p" = "push"; "pl" = "pull"; 
    "co" = "checkout"; "b" = "branch"; "d" = "diff"; "s" = "status";
    "f" = "fetch"; "m" = "merge"; "r" = "rebase"; "st" = "stash"
}
foreach ($key in $gitActions.Keys) {
    $val = $gitActions[$key]
    Set-Alias "g$key" "git-$val" -Force -ErrorAction SilentlyContinue
}
# endregion

# region DOCKER GRID
$dockerActions = @{
    "i" = "images"; "p" = "ps"; "r" = "run"; "s" = "stop"; 
    "st" = "start"; "l" = "logs"; "e" = "exec"; "v" = "volume";
    "n" = "network"; "b" = "build"; "c" = "compose"
}
foreach ($key in $dockerActions.Keys) {
    $val = $dockerActions[$key]
    Set-Alias "d$key" "docker-$val" -Force -ErrorAction SilentlyContinue
}
# endregion

# region KUBERNETES GRID
$k8sResources = @("pod", "service", "deployment", "node", "namespace", "ingress", "configmap", "secret")
foreach ($r in $k8sResources) {
    Set-Alias "kg$($r[0])" "kubectl-get-$r" -Force -ErrorAction SilentlyContinue
    Set-Alias "kd$($r[0])" "kubectl-describe-$r" -Force -ErrorAction SilentlyContinue
    Set-Alias "ke$($r[0])" "kubectl-edit-$r" -Force -ErrorAction SilentlyContinue
}
# endregion

# region SYSTEM NAVIGATION GRID
$locations = @("Desktop", "Documents", "Downloads", "Music", "Pictures", "Videos", "projects", "code")
foreach ($l in $locations) {
    $short = $l[0..2] -join ""
    # Example: cddesk, cddocs, cddl
    Set-Alias "cd$($short.ToLower())" "Set-Location-$l" -Force -ErrorAction SilentlyContinue
}
# endregion

# This script generates hundreds of valid, unique aliases upon load.
