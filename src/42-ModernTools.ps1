# PowerConfig Modern Tools - Ultra Optimized Integration
# https://github.com/thepinak503/powerconfig

#region EZA (Modern ls replacement)
if ($Cmds.Eza) {
    Remove-Item Alias:\ls -EA SilentlyContinue
    function ls { eza --group-directories-first --icons @args }
    function l { eza -la --group-directories-first --icons @args }
    function la { eza -a --group-directories-first --icons @args }
    function ll { eza -l --group-directories-first --icons @args }
    function lt { eza --tree --level=2 --icons @args }
    function ltt { eza --tree --level=3 --icons @args }
    function ltl { eza --tree --level=2 --long --icons @args }
    function lsize { eza -la --sort=size --reverse @args }
    function ltime { eza -la --sort=modified --reverse @args }
    function lext { eza -la --sort=extension @args }
    function lname { eza -la --sort=name @args }
    function l. { eza -d .* @args }
    function lg { eza -la --git @args }
    function l1 { eza -1 @args }
    
    Set-Alias l ls
    Set-Alias la ls
    Set-Alias ll ls
}
#endregion

#region BAT (Cat with syntax highlighting)
if ($Cmds.Bat) {
    $env:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
    $env:MANROFFOPT = "-c"
    
    function cat { bat --style=header,grid @args }
    function catn { bat --style=numbers @args }
    function catp { bat --style=plain --paging=never @args }
    function cath { bat --style=header @args }
    function catl { bat --style=header,grid --paging=always @args }
}
#endregion

#region RIPGREP (Ultra fast grep)
if ($Cmds.Rg) {
    Remove-Item Alias:\grep -EA SilentlyContinue
    Remove-Item Function:\grep -EA SilentlyContinue
    
    function grep { rg --color=always @args }
    function rgi { rg -i @args }
    function rgv { rg -v @args }
    function rgl { rg -l @args }
    function rgn { rg -n @args }
    function rgc { rg -c @args }
    function rgw { rg -w @args }
    function rgt { rg --type @args }
    function rgff { rg --files-with-matches @args }
    function rgpy { rg -t py @args }
    function rgjs { rg -t js @args }
    function rgts { rg -t ts @args }
    function rgmd { rg -t md @args }
    function rgrs { rg -t rust @args }
    function rggo { rg -t go @args }
    function rgjava { rg -t java @args }
    function rgsh { rg -t sh @args }
    function rgps1 { rg -t ps1 @args }
    
    Set-Alias grep rg
}
#endregion

#region FD (Modern find)
if ($Cmds.Fd) {
    Remove-Item Alias:\find -EA SilentlyContinue
    Remove-Item Function:\find -EA SilentlyContinue
    
    function find { fd @args }
    function ff { fd --type f @args }
    function fdir { fd --type d @args }
    function ffi { fd -i @args }
    function ffh { fd --hidden @args }
    function ffe { fd -e @args }
    function fpy { fd -e py @args }
    function fjs { fd -e js @args }
    function fts { fd -e ts @args }
    function fmd { fd -e md @args }
    function fjson { fd -e json @args }
    function fgit { fd --hidden --exclude .git @args }
    
    Set-Alias find fd
}
#endregion

#region DELTA (Beautiful git diffs)
if ($Cmds.Delta) {
    git config --global core.pager delta 2>$null
    git config --global interactive.diffFilter 'delta --color-only' 2>$null
    git config --global delta.navigate true 2>$null
    git config --global delta.light false 2>$null
    git config --global merge.conflictStyle diff3 2>$null
    git config --global diff.colorMoved default 2>$null
    git config --global delta.side-by-side false 2>$null
    git config --global delta.header-decoration "bold" 2>$null
    git config --global delta.hunk-header-decoration-style "box" 2>$null
    git config --global delta.hunk-header-file-style "yellow" 2>$null
    git config --global delta.hunk-header-line-number-style "green" 2>$null
    
    function gd { git diff @args | less -R }
    function gds { git diff --staged @args | less -R }
    function gdc { git diff --cached @args | less -R }
}
#endregion

#region DUST (Modern du)
if ($Cmds.Dust) {
    function du { dust @args }
    function du. { dust -d 1 @args }
    function du1 { dust -d 1 @args }
    function du2 { dust -d 2 @args }
    function du3 { dust -d 3 @args }
    function dub { dust -b @args }
}
#endregion

#region DUF (Modern df)
if ($Cmds.Duf) {
    function df { duf @args }
}
#endregion

#region PROCS (Modern ps)
if ($Cmds.Procs) {
    Remove-Item Alias:\ps -EA SilentlyContinue
    Remove-Item Function:\ps -EA SilentlyContinue
    
    function ps { procs @args }
    function pstree { procs --tree @args }
    function pswatch { watch -n1 procs @args }
    
    Set-Alias ps procs
}
#endregion

#region BTOP (Modern htop)
if ($Cmds.Btop) {
    function top { btop @args }
    function htop { btop @args }
    function btop { btop @args }
}
#endregion

#region FZF (Fuzzy Finder)
if ($Cmds.Fzf) {
    $env:FZF_DEFAULT_OPTS = @"
--height=40%
--layout=reverse
--border
--preview-window=right:50%
--multi
--marker=+
--tabstop=4
--italic
--color=bg+:#2d3142,bg:#1a1b26,spinner:#f9e2af,hl:#7aa2f7,fg:#c0caf5,header:#7aa2f7,info:#9ece6a,pointer:#f7768e,marker:#f7768e,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7
"@
    
    $env:FZF_DEFAULT_COMMAND = if ($Cmds.Fd) { "fd --type f --hidden --follow --exclude .git" } else { "find . -type f" }
    
    function fcd {
        $dir = if ($Cmds.Fd) {
            fd --type d --hidden --follow --exclude .git | fzf --preview 'ls -la {}'
        } else {
            find . -type d | fzf --preview 'ls -la {}'
        }
        if ($dir) { Set-Location $dir }
    }
    
    function fe {
        $files = if ($Cmds.Fd) {
            fd --type f --hidden --follow --exclude .git | fzf --multi --preview 'bat --style=numbers --color=always --line-range :100 {}'
        } else {
            find . -type f | fzf --multi --preview 'bat --style=numbers --color=always --line-range :100 {}'
        }
        if ($files) { & $env:EDITOR $files }
    }
    
    function fbr {
        $branch = git branch -vv | fzf --height=20 --reverse +m
        if ($branch) {
            $branchName = ($branch -split "\s+")[0] -replace "^\*?\s*", ""
            git checkout $branchName
        }
    }
    
    function fhist {
        $cmd = Get-History | ForEach-Object { $_.CommandLine } | fzf --tac
        if ($cmd) { Invoke-Expression $cmd }
    }
    
    function fkill {
        $process = Get-Process | Select-Object Id, ProcessName, CPU | fzf --multi --header="[kill process]" | ForEach-Object { $_.Id }
        if ($process) { Stop-Process -Id $process -Force }
    }
    
    function fenv {
        Get-ChildItem Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | fzf | ForEach-Object {
            $parts = $_ -split '='
            Set-Item "env:$($parts[0])" ($parts[1..($parts.Length-1)] -join '=')
        }
    }
    
    function fshow {
        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
        fzf --ansi --no-sort --reverse --tiebreak=index |
        ForEach-Object { ($_ -split "\s+")[0] } |
        ForEach-Object { git show --color=always $_ | less -R }
    }
    
    function fstash {
        git stash list | fzf --height=20 --reverse | ForEach-Object {
            $idx = ($_ -split ':')[0]
            git stash pop "stash@{$idx}"
        }
    }
    
    function ft {
        if ($Cmds.Fd) {
            fd --type f @args | fzf --preview 'bat --style=numbers --color=always {}'
        } else {
            find . -type f @args | fzf --preview 'bat --style=numbers --color=always {}'
        }
    }
    
    function fco {
        git checkout (git branch -vv | fzf --height=20 --reverse +m | ForEach-Object { ($_ -split "\s+")[0] -replace "^\*?\s*", "" })
    }
}
#endregion

#region ZOXIDE (Smart directory jumping)
if ($Cmds.Zoxide) {
    Invoke-Expression (& { (zoxide init powershell 2>$null | Out-String) })
    
    function z { __zoxide_z @args }
    function zi { __zoxide_zi @args }
    function za { zoxide add @args }
    function zq { zoxide query @args }
    function zr { zoxide remove @args }
    function zl { zoxide query --list @args }
}
#endregion

#region FASTFETCH (System info)
if ($Cmds.Fastfetch) {
    function sysinfo { fastfetch @args }
    function neofetch { fastfetch @args }
} elseif ($Cmds.Onefetch) {
    function sysinfo { onefetch @args }
}
#endregion

#region ONEFETCH (Repo info)
if ($Cmds.Onefetch) {
    function repo { onefetch @args }
    function onefetch { onefetch @args }
}
#endregion

#region TOKEI (Code statistics)
if ($Cmds.Tokei) {
    function lines { tokei @args }
    function tokei { tokei @args }
    function cloc { tokei @args }
}
#endregion

#region TLDR (Simplified man pages)
if ($Cmds.Tldr) {
    function tldr { tlrc @args }
}
#endregion

#region LAZYGIT
if ($Cmds.Lazygit) {
    function lg { lazygit @args }
    function lazygit { lazygit @args }
}
#endregion

#region GIT
if ($Cmds.Git) {
    $env:GIT_EDITOR = if ($Cmds.Neovim) { "nvim" } elseif ($Cmds.VSCode) { "code --wait" } else { $env:EDITOR }
    $env:GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
    
    function gs { git status -sb @args }
    function ga { git add @args }
    function gaa { git add --all @args }
    function gc { git commit @args }
    function gcm { git commit -m @args }
    function gca { git commit --amend @args }
    function gco { git checkout @args }
    function gcb { git checkout -b @args }
    function gd { git diff @args }
    function gds { git diff --staged @args }
    function gf { git fetch @args }
    function gfa { git fetch --all @args }
    function gp { git push @args }
    function gpf { git push --force-with-lease @args }
    function gpl { git pull @args }
    function gl { git log --oneline --graph --decorate @args }
    function gst { git stash @args }
    function gstp { git stash pop @args }
    function gsta { git stash apply @args }
    function gstl { git stash list }
    function gr { git rebase @args }
    function gri { git rebase -i @args }
    function gsl { git stash list }
    
    Set-Alias g git
}
#endregion

#region GITHUB CLI
if ($Cmds.GH) {
    function ghp { gh repo sync @args }
    function ghp { gh pr @args }
    function ghi { gh issue @args }
    function ghc { gh run @args }
}
#endregion

#region DOCKER
if ($Cmds.Docker) {
    function d { docker @args }
    function dc { docker-compose @args }
    function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
    function dpa { docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
    function dex { param($c) docker exec -it $c pwsh }
    function dexsh { param($c) docker exec -it $c sh }
    function dr { param($i) docker run -it --rm $i }
    function dri { param($i) docker run -it $i }
    function dprune { docker system prune -af }
    function dstats { docker stats --no-stream }
    function dtop { docker stats }
    function dlogs { docker logs -f @args }
    function dstop { docker stop @args }
    function dstart { docker start @args }
    
    # Docker Compose
    function dcu { docker-compose up @args }
    function dcud { docker-compose up -d @args }
    function dcd { docker-compose down @args }
    function dcr { docker-compose restart @args }
    function dcl { docker-compose logs -f @args }
    function dcb { docker-compose build @args }
    function dcs { docker-compose stop @args }
    function dce { docker-compose exec @args }
    function dcp { docker-compose pull @args }
    function dcrb { docker-compose up -d --build @args }
    
    Set-Alias docker d
    Set-Alias dcomp dc
}
#endregion

#region KUBECTL
if ($Cmds.Kubectl) {
    function k { kubectl @args }
    function kg { kubectl get @args }
    function kd { kubectl describe @args }
    function kl { kubectl logs @args }
    function kex { kubectl exec -it @args }
    function kgp { kubectl get pods @args }
    function kgs { kubectl get svc @args }
    function kgd { kubectl get deployment @args }
    function kgn { kubectl get nodes @args }
    function kdp { kubectl describe pod @args }
    function kpf { kubectl port-forward @args }
    function ka { kubectl apply @args }
    function kdel { kubectl delete @args }
    function ktop { kubectl top @args }
    function krun { kubectl run @args }
    function kctx { kubectl config current-context }
    function kns { param($n) kubectl config set-context --current --namespace=$n }
    
    Set-Alias kubectl k
}
#endregion

#region HYPERFINE (Benchmarking)
if ($Cmds.Hyperfine) {
    function benchmark { hyperfine @args }
    function bench { hyperfine @args }
}
#endregion

#region COMPLETIONS
if ($Cmds.Fzf) {
    # SSH completion
    Set-PSReadLineOption -AddToHistoryHandler {
        param([string]$Line)
        $Line -match '^ssh '
    }
}
#endregion

#region RIPGREP CONFIG
if ($Cmds.Rg) {
    # Create ripgreprc if it doesn't exist
    $ripgreprc = if ($IsWindows) { "$env:USERPROFILE\.ripgreprc" } else { "$env:HOME/.ripgreprc" }
    if (-not (Test-Path $ripgreprc)) {
        @"
--smart-case
--hidden
--glob=!.git/*

# Colors
--colors=line:fg:yellow
--colors=line:style:bold
--colors=path:fg:green
--colors=match:fg:cyan
--colors=match:style:bold
"@ | Out-File -FilePath $ripgreprc -Encoding UTF8
    }
}
#endregion

#region EDITOR CONFIGURATIONS
# Neovim remote
if ($Cmds.Neovim) {
    $env:NVIM_LISTEN_ADDRESS = "\\.\pipe\nvim"
}

# VSCode integrated terminal
if ($Cmds.VSCode) {
    function code-workspace {
        code --folder-uri "vscode-remote://localhost:5831/home/user/project"
    }
}
#endregion
