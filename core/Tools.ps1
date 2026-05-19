function Has-Cmd { param($cmd) $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

$global:POWERCONFIG_TOOLS = @{}
$toolList = @(
    'git','curl','wget','tar','gzip','unzip','openssl',
    'starship','zoxide','fzf',
    'eza','bat','fd','rg','delta','ncdu','duf','dust',
    'nvim','tmux','lazygit','fastfetch','btop','glow','tldr',
    'docker','kubectl','helm','terraform',
    'aws','gcloud','az',
    'jq','yq','hyperfine','tokei','gping','procs',
    'gh','winget','scoop','choco','pwsh','python','node','go','rustc','cargo'
)
foreach ($t in $toolList) {
    $global:POWERCONFIG_TOOLS[$t] = Has-Cmd $t
}

$global:Cmds = $global:POWERCONFIG_TOOLS

$DOTTOOLS_CORE = @('git','curl','wget','tar','gzip','unzip','openssl')
$DOTTOOLS_SHELL = @('starship','zoxide','fzf')
$DOTTOOLS_FILES = @('eza','bat','fd','rg','delta','ncdu','duf','dust')
$DOTTOOLS_DEV = @('nvim','tmux','lazygit','fastfetch','btop','glow','tldr')
$DOTTOOLS_DEVOPS = @('docker','kubectl','helm','terraform','aws','az')
$DOTTOOLS_SECURITY = @('openssl')
$DOTTOOLS_EXTRAS = @('jq','yq','hyperfine','tokei','gping','procs','gh')

$c_reset = "$([char]27)[0m"
$c_bold = "$([char]27)[1m"
$c_green = "$([char]27)[32m"
$c_yellow = "$([char]27)[33m"
$c_red = "$([char]27)[31m"
$c_cyan = "$([char]27)[36m"
$c_magenta = "$([char]27)[35m"

function global:dottools {
    Write-Host "$($c_bold)$($c_magenta)"
    Write-Host "+--------------------------------------------+"
    Write-Host "|      POWERCONFIG TOOL STATUS REPORT        |"
    Write-Host "+--------------------------------------------+$($c_reset)"
    Write-Host "  OS: $($c_cyan)$env:DOTFILES_OS$($c_reset) | Shell: $($c_cyan)$env:POWERCONFIG_SHELL$($c_reset)"

    $section = { Write-Host "`n$($c_bold)$($c_cyan)>> $($args[0])$($c_reset)" }

    & $section "CORE (required)"
    foreach ($t in $DOTTOOLS_CORE) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [!] $t - MISSING" }
    }

    & $section "SHELL (recommended)"
    foreach ($t in $DOTTOOLS_SHELL) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t" }
    }

    & $section "FILES (recommended)"
    foreach ($t in $DOTTOOLS_FILES) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t" }
    }

    & $section "DEVELOPER (recommended)"
    foreach ($t in $DOTTOOLS_DEV) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t" }
    }

    & $section "DEVOPS (optional)"
    foreach ($t in $DOTTOOLS_DEVOPS) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t (optional)" }
    }

    & $section "SECURITY (recommended)"
    foreach ($t in $DOTTOOLS_SECURITY) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t" }
    }

    & $section "EXTRAS (optional)"
    foreach ($t in $DOTTOOLS_EXTRAS) {
        if ($global:POWERCONFIG_TOOLS[$t]) { Write-Host "  [+] $t" } else { Write-Host "  [-] $t (optional)" }
    }

    $total = ($DOTTOOLS_CORE + $DOTTOOLS_SHELL + $DOTTOOLS_FILES + $DOTTOOLS_DEV + $DOTTOOLS_DEVOPS + $DOTTOOLS_SECURITY + $DOTTOOLS_EXTRAS).Count
    $installed = ($global:POWERCONFIG_TOOLS.Keys | Where-Object { $global:POWERCONFIG_TOOLS[$_] }).Count
    Write-Host "`n$($c_bold)Summary: $installed/$total installed$($c_reset)"
    Write-Host "Run $($c_cyan)dotinstall$($c_reset) for install commands.`n"
}

function global:dotphase {
    Write-Host "$($c_bold)$($c_cyan)Active feature phases:$($c_reset)"
    $phases = @{
        starship = 'Prompt'
        zoxide = 'SmartCD'
        fzf = 'FuzzyFinder'
        eza = 'ModernLS'
        bat = 'SyntaxCat'
        fd = 'FastFind'
        rg = 'FastGrep'
        delta = 'GitDiff'
        nvim = 'Editor'
        tmux = 'Multiplexer'
        lazygit = 'GitTUI'
        fastfetch = 'SysInfo'
        docker = 'Containers'
        kubectl = 'Kubernetes'
        terraform = 'IaC'
        btop = 'ProcessView'
        jq = 'JSON'
    }
    foreach ($pair in $phases.GetEnumerator()) {
        $tool = $pair.Key
        $label = $pair.Value
        if ($global:POWERCONFIG_TOOLS[$tool]) {
            Write-Host "  [*] $label - ACTIVE"
        } else {
            Write-Host "  [ ] $label - DISABLED (install $tool)"
        }
    }
    Write-Host ""
}

$hints = @{
    starship  = @{desc='Smart prompt'; winget='Starship.Starship'; scoop='starship'; choco='starship'}
    zoxide    = @{desc='Smart cd';     winget='ajeetdsouza.zoxide'; scoop='zoxide'; choco='zoxide'}
    fzf       = @{desc='Fuzzy finder';  winget='junegunn.fzf';     scoop='fzf';    choco='fzf'}
    eza       = @{desc='Modern ls';     winget='eza-community.eza'; scoop='eza';   choco='eza'}
    bat       = @{desc='Syntax cat';    winget='sharkdp.bat';       scoop='bat';   choco='bat'}
    fd        = @{desc='Fast find';     winget='sharkdp.fd';        scoop='fd';    choco='fd'}
    rg        = @{desc='Fast grep';     winget='BurntSushi.ripgrep.MSVC'; scoop='ripgrep'; choco='ripgrep'}
    delta     = @{desc='Git diff';      winget='dandavison.delta';  scoop='delta'; choco='git-delta'}
    nvim      = @{desc='Neovim';        winget='Neovim.Neovim';     scoop='neovim'; choco='neovim'}
    lazygit   = @{desc='Git TUI';       winget='GitButler.lazygit'; scoop='lazygit'; choco='lazygit'}
    fastfetch = @{desc='Sys info';      winget='fastfetch';         scoop='fastfetch'; choco='fastfetch'}
    docker    = @{desc='Containers';    winget='Docker.DockerDesktop'; scoop='docker'; choco='docker'}
    kubectl   = @{desc='K8s CLI';       winget='Kubernetes.kubectl'; scoop='kubectl'; choco='kubernetes-cli'}
    terraform = @{desc='IaC';           winget='Hashicorp.Terraform'; scoop='terraform'; choco='terraform'}
    btop      = @{desc='Process view';  winget='btop-labs.btop';    scoop='btop';  choco='btop'}
    jq        = @{desc='JSON proc';     winget='jqlang.jq';         scoop='jq';    choco='jq'}
}

function global:dotinstall {
    $pkg = $env:DOTFILES_PKG_MANAGER
    Write-Host "$($c_bold)$($c_cyan)Missing tools - install commands for: $pkg$($c_reset)`n"
    $any = $false
    $missing = $global:POWERCONFIG_TOOLS.Keys | Where-Object { -not $global:POWERCONFIG_TOOLS[$_] }
    foreach ($t in $missing) {
        if ($hints.ContainsKey($t)) {
            $h = $hints[$t]
            $any = $true
            Write-Host "  $t - $($h.desc)"
            Write-Host "    winget: winget install $($h.winget)"
            Write-Host "    scoop:  scoop install $($h.scoop)"
            Write-Host "    choco:  choco install $($h.choco)"
        }
    }
    if (-not $any) { Write-Host "  All recommended tools installed!" }
}

$null = $global:Cmds
