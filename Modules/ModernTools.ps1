# PowerConfig Modern Tools
# Starship, FZF, Zoxide, Eza, Bat, Ripgrep, Delta integration

#region Eza (Modern ls)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    # Main replacements
    function ls { eza --group-directories-first --icons $args }
    function l { eza -la --group-directories-first --icons $args }
    function la { eza -a --group-directories-first --icons $args }
    function ll { eza -l --group-directories-first --icons $args }
    
    # Tree view
    function lt { eza --tree --level=2 --icons $args }
    function ltt { eza --tree --level=3 --icons $args }
    function ltl { eza --tree --level=2 --long --icons $args }
    
    # Sorting
    function lsize { eza -la --sort=size --reverse --icons $args }
    function ltime { eza -la --sort=modified --reverse --icons $args }
    function lold { eza -la --sort=modified --icons $args }
    function lext { eza -la --sort=extension --icons $args }
    function lname { eza -la --sort=name --icons $args }
    
    # Hidden files
    function l. { eza -d --icons .* $args }
    function lah { eza -la --icons $args }
    
    # One column
    function l1 { eza -1 --icons $args }
    
    # Git integration
    function lg { eza -la --git --icons $args }
    function lgi { eza -la --git-ignore --icons $args }
    
    Write-Host "✓ Eza aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Exa (fallback)
elseif (Get-Command exa -ErrorAction SilentlyContinue) {
    function ls { exa --group-directories-first --icons $args }
    function l { exa -la --group-directories-first --icons $args }
    function la { exa -a --group-directories-first --icons $args }
    function ll { exa -l --group-directories-first --icons $args }
    function lt { exa --tree --level=2 --icons $args }
    
    Write-Host "✓ Exa aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Bat (cat with syntax highlighting)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --style=header,grid $args }
    function catp { bat --style=plain --paging=never $args }
    function catl { bat --style=header,grid --paging=always $args }
    function catn { bat --style=numbers $args }
    
    $env:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
    $env:MANROFFOPT = "-c"
    
    Write-Host "✓ Bat aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Ripgrep (rg)
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg --color=always $args }
    function rgi { rg -i $args }
    function rgv { rg -v $args }
    function rgf { rg -F $args }
    function rgw { rg -w $args }
    function rgc { rg -c $args }
    function rgl { rg -l $args }
    function rgno { rg --no-heading $args }
    function rgn { rg -n $args }
    function rgff { rg --files-with-matches $args }
    
    # File type shortcuts
    function rgpy { rg -t py $args }
    function rgjs { rg -t js $args }
    function rgjsts { rg -t js -t ts $args }
    function rgmd { rg -t md $args }
    function rgrs { rg -t rust $args }
    function rggo { rg -t go $args }
    function rgc { rg -t c -t cpp $args }
    function rgjava { rg -t java $args }
    function rgphp { rg -t php $args }
    function rgrb { rg -t rb $args }
    
    Write-Host "✓ Ripgrep aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region FD (find replacement)
if (Get-Command fd -ErrorAction SilentlyContinue) {
    function find { fd $args }
    function ff { fd --type f $args }
    function fdir { fd --type d $args }
    function fhidden { fd --hidden $args }
    function ffi { fd -i $args }
    function fabs { fd --absolute-path $args }
    function ffollow { fd --follow $args }
    function fexec { fd --exec $args }
    
    # Extensions
    function fpy { fd -e py $args }
    function fjs { fd -e js $args }
    function fts { fd -e ts $args }
    function frs { fd -e rs $args }
    function fmd { fd -e md $args }
    function flog { fd -e log $args }
    
    Write-Host "✓ FD aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Delta (git diff viewer)
if (Get-Command delta -ErrorAction SilentlyContinue) {
    # Configure git to use delta
    git config --global core.pager delta 2>$null
    git config --global interactive.diffFilter 'delta --color-only' 2>$null
    git config --global delta.navigate true 2>$null
    git config --global delta.light false 2>$null
    git config --global merge.conflictStyle diff3 2>$null
    git config --global diff.colorMoved default 2>$null
    
    Write-Host "✓ Delta configured for Git" -ForegroundColor DarkGray
}
#endregion

#region Dust (du replacement)
if (Get-Command dust -ErrorAction SilentlyContinue) {
    function du { dust $args }
    function du. { dust -d 1 $args }
    function du1 { dust -d 1 $args }
    function du2 { dust -d 2 $args }
    function du3 { dust -d 3 $args }
    
    Write-Host "✓ Dust aliases loaded" -ForegroundColor DarkGray
}
#endregion

#region Btop/Bpytop
if (Get-Command btop -ErrorAction SilentlyContinue) {
    function top { btop }
    function htop { btop }
    
    Write-Host "✓ Btop configured" -ForegroundColor DarkGray
}
elseif (Get-Command bpytop -ErrorAction SilentlyContinue) {
    function top { bpytop }
    function htop { bpytop }
    
    Write-Host "✓ Bpytop configured" -ForegroundColor DarkGray
}
#endregion

#region Procs (ps replacement)
if (Get-Command procs -ErrorAction SilentlyContinue) {
    function ps { procs $args }
    
    Write-Host "✓ Procs configured" -ForegroundColor DarkGray
}
#endregion

#region SD (sed replacement)
if (Get-Command sd -ErrorAction SilentlyContinue) {
    # Use sd for find and replace
    Write-Host "✓ SD available for text replacement" -ForegroundColor DarkGray
}
#endregion

#region Hyperfine (benchmarking)
if (Get-Command hyperfine -ErrorAction SilentlyContinue) {
    Write-Host "✓ Hyperfine available for benchmarking" -ForegroundColor DarkGray
}
#endregion

#region Duf (df replacement)
if (Get-Command duf -ErrorAction SilentlyContinue) {
    function df { duf $args }
    
    Write-Host "✓ Duf configured" -ForegroundColor DarkGray
}
#endregion

#region Dog (dig replacement)
if (Get-Command dog -ErrorAction SilentlyContinue) {
    function dig { dog $args }
    
    Write-Host "✓ Dog configured" -ForegroundColor DarkGray
}
#endregion

#region FZF Functions
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Fuzzy cd
    function fcd {
        if (Get-Command fd -ErrorAction SilentlyContinue) {
            $dir = fd --type d --hidden --follow --exclude .git | fzf --preview 'tree -C {} | head -20'
        } else {
            $dir = Get-ChildItem -Recurse -Directory -Hidden | Where-Object { $_.FullName -notlike "*\.git*" } | 
                    Select-Object FullName | fzf --preview 'tree -C {} | head -20'
        }
        if ($dir) { 
            if ($dir -is [string]) {
                Set-Location $dir
            } else {
                Set-Location $dir.FullName
            }
        }
    }
    
    # Fuzzy edit
    function fe {
        if (Get-Command fd -ErrorAction SilentlyContinue) {
            $files = fd --type f --hidden --follow --exclude .git | fzf --multi --preview 'bat --style=numbers --color=always --line-range :500 {}'
        } else {
            $files = Get-ChildItem -Recurse -File -Hidden | Where-Object { $_.FullName -notlike "*\.git*" } | 
                    Select-Object FullName | fzf --multi
        }
        if ($files) { 
            if ($files -is [string]) {
                & $env:EDITOR $files
            } else {
                & $env:EDITOR $files.FullName
            }
        }
    }
    
    # Fuzzy git checkout
    function fbr {
        $branch = git branch -vv 2>$null | fzf --height=20 --reverse +m
        if ($branch) {
            $branchName = ($branch -split "\s+")[0] -replace "^\*?\s*", ""
            git checkout $branchName
        }
    }
    
    # Fuzzy git log
    function fshow {
        git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" 2>$null |
        fzf --ansi --no-sort --reverse --tiebreak=index |
        ForEach-Object { ($_ -split "\s+")[0] } |
        ForEach-Object { git show --color=always $_ | less -R }
    }
    
    # Fuzzy kill
    function fkill {
        if ($IsWindows) {
            $process = Get-Process | Select-Object Id, ProcessName, CPU | fzf --multi --header="[kill process]"
            if ($process) {
                $ids = $process | ForEach-Object { $_.Id }
                Stop-Process -Id $ids -Force
            }
        } else {
            $process = ps aux | fzf --multi --header="[kill process]" | ForEach-Object { ($_ -split '\s+')[1] }
            if ($process) {
                kill -9 $process
            }
        }
    }
    
    # Fuzzy environment
    function fenv {
        Get-ChildItem Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } | fzf
    }
    
    # Fuzzy history
    function fhist {
        $cmd = Get-History | ForEach-Object { $_.CommandLine } | fzf --tac
        if ($cmd) { Invoke-Expression $cmd }
    }
    
    Write-Host "✓ FZF functions loaded" -ForegroundColor DarkGray
}
#endregion

#region Zoxide Aliases
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # zoxide is initialized in main profile
    # Additional aliases
    function z { __zoxide_z $args }
    function zi { __zoxide_zi $args }
    function za { zoxide add $args }
    function zq { zoxide query $args }
    function zr { zoxide remove $args }
    
    Write-Host "✓ Zoxide configured" -ForegroundColor DarkGray
}
#endregion

#region Fastfetch/Neofetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    function sysinfo { fastfetch }
    
    Write-Host "✓ Fastfetch configured" -ForegroundColor DarkGray
}
elseif (Get-Command neofetch -ErrorAction SilentlyContinue) {
    function sysinfo { neofetch }
    
    Write-Host "✓ Neofetch configured" -ForegroundColor DarkGray
}
#endregion

#region OneFetch
if (Get-Command onefetch -ErrorAction SilentlyContinue) {
    function repo { onefetch }
    
    Write-Host "✓ OneFetch available" -ForegroundColor DarkGray
}
#endregion

#region Tokei (code statistics)
if (Get-Command tokei -ErrorAction SilentlyContinue) {
    function lines { tokei $args }
    
    Write-Host "✓ Tokei available for code statistics" -ForegroundColor DarkGray
}
#endregion

#region Tldr (simplified man pages)
if (Get-Command tldr -ErrorAction SilentlyContinue) {
    function help { tldr $args }
    
    Write-Host "✓ Tldr available for simplified help" -ForegroundColor DarkGray
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
#endregion

#region Cross-Platform Automation Tools
if ($IsWindows) {
    if (Get-Command nircmd -ErrorAction SilentlyContinue) {
        Write-Host "✓ Nircmd available for Windows automation" -ForegroundColor DarkGray
    }
} elseif ($IsMacOS) {
    if (Get-Command cliclick -ErrorAction SilentlyContinue) {
        Write-Host "✓ Cliclick available for macOS automation" -ForegroundColor DarkGray
    }
} elseif ($IsLinux) {
    if (Get-Command xdotool -ErrorAction SilentlyContinue) {
        Write-Host "✓ XDoTool available for Linux automation" -ForegroundColor DarkGray
    }
}
#endregion
