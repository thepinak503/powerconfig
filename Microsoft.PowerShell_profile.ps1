# PowerConfig - Ultimate PowerShell Configuration
# https://github.com/thepinak503/powerconfig
# Version: 1.0.0

#region Cross-Platform Configuration
$env:POWERCONFIG_VERSION = "1.0.0"
$env:POWERCONFIG_MODE = if ($env:POWERCONFIG_MODE) { $env:POWERCONFIG_MODE } else { "advanced" }

if ($IsWindows) {
    $env:POWERCONFIG_DIR = "$env:USERPROFILE\.powerconfig"
} else {
    $env:POWERCONFIG_DIR = "$env:HOME/.powerconfig"
}
#endregion

#region Core Environment
# Editor preference
if (Get-Command code -ErrorAction SilentlyContinue) {
    $env:EDITOR = "code"
    $env:VISUAL = "code"
} elseif (Get-Command nvim -ErrorAction SilentlyContinue) {
    $env:EDITOR = "nvim"
    $env:VISUAL = "nvim"
} elseif (Get-Command vim -ErrorAction SilentlyContinue) {
    $env:EDITOR = "vim"
    $env:VISUAL = "vim"
} else {
    $env:EDITOR = "notepad"
    $env:VISUAL = "notepad"
}

# Locale
$env:LANG = "en_US.UTF-8"

# Starship Config Path
if ($IsWindows) {
    $env:STARSHIP_CONFIG = "$env:USERPROFILE\.powerconfig\starship.toml"
} else {
    $env:STARSHIP_CONFIG = "$env:HOME/.powerconfig/starship.toml"
}

# Disable annoying prompts
$env:VIRTUAL_ENV_DISABLE_PROMPT = "1"
$env:PYTHONDONTWRITEBYTECODE = "1"
$env:NODE_NO_WARNINGS = "1"
#endregion

#region Cross-Platform PATH Management
$PathAdditions = @(
    "$env:HOME/.local/bin",
    "$env:HOME/.cargo/bin",
    "$env:HOME/.dotnet/tools",
    "$env:HOME/.npm-global/bin",
    "$env:HOME/.poetry/bin",
    "$env:HOME/go/bin",
    "$env:HOME/scoop/shims",
    "$env:HOME/scoop/apps/git/current/bin",
    "$env:HOME/scoop/apps/python/current",
    "$env:HOME/AppData/Local/Microsoft/WindowsApps",
    "$env:HOME/AppData/Roaming/Python/Scripts",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    "/usr/local/sbin",
    "/usr/sbin",
    "/sbin"
)

foreach ($Path in $PathAdditions) {
    if ((Test-Path $Path) -and ($env:Path -notlike "*$Path*")) {
        $env:Path = "$Path;$env:Path"
    }
}
#endregion

#region Load PowerConfig Components
$ComponentPath = "$env:POWERCONFIG_DIR\Modules"

# Load Aliases
$AliasesFile = "$ComponentPath\Aliases.ps1"
if (Test-Path $AliasesFile) { . $AliasesFile }

# Load Functions
$FunctionsFile = "$ComponentPath\Functions.ps1"
if (Test-Path $FunctionsFile) { . $FunctionsFile }

# Load Package Managers
$PkgFile = "$ComponentPath\PackageManagers.ps1"
if (Test-Path $PkgFile) { . $PkgFile }

# Load Development Tools
if ($env:POWERCONFIG_MODE -ne "basic") {
    $DevFile = "$ComponentPath\Development.ps1"
    if (Test-Path $DevFile) { . $DevFile }
}

# Load Modern Tools
if ($env:POWERCONFIG_MODE -ne "basic") {
    $ToolsFile = "$ComponentPath\ModernTools.ps1"
    if (Test-Path $ToolsFile) { . $ToolsFile }
}

# Load Cross-Platform System
$WinFile = "$ComponentPath\Windows.ps1"
if (Test-Path $WinFile) { . $WinFile }
#endregion

#region Modern Tool Initialization
# Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# FZF
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $FzfPath = if (Test-Path "$env:USERPROFILE\scoop\apps\fzf\current") {
        "$env:USERPROFILE\scoop\apps\fzf\current"
    } else {
        (Get-Command fzf).Source | Split-Path
    }
    
    $FzfBindings = "$FzfPath\shell\key-bindings.ps1"
    if (Test-Path $FzfBindings) { . $FzfBindings }
}

# PSReadLine Configuration
if (Get-Module PSReadLine -ListAvailable) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# Terminal-Icons
if (Get-Module Terminal-Icons -ListAvailable) {
    Import-Module Terminal-Icons
}
#endregion

#region Custom Prompt (if no Starship)
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    function prompt {
        $location = Get-Location
        $branch = ""
        
        # Git branch
        try {
            $branch = git branch --show-current 2>$null
            if ($branch) { $branch = " ($branch)" }
        } catch {}
        
        # Status indicator
        $status = if ($?) { "✓" } else { "✗" }
        $statusColor = if ($?) { "Green" } else { "Red" }
        
        # Build prompt
        Write-Host "$status " -NoNewline -ForegroundColor $statusColor
        Write-Host "$env:USERNAME@$env:COMPUTERNAME " -NoNewline -ForegroundColor Cyan
        Write-Host "$location" -NoNewline -ForegroundColor Yellow
        if ($branch) {
            Write-Host "$branch" -NoNewline -ForegroundColor Magenta
        }
        Write-Host "`n> " -NoNewline
        return " "
    }
}
#endregion

#region Welcome Message
switch ($env:POWERCONFIG_MODE) {
    "ultra-nerd" { Write-Host "✓ PowerConfig loaded in ULTRA-NERD mode" -ForegroundColor Green }
    "basic" { Write-Host "✓ PowerConfig loaded in BASIC mode" -ForegroundColor Blue }
    default { Write-Host "✓ PowerConfig loaded in ADVANCED mode" -ForegroundColor DarkYellow }
}
#endregion

#region Local Customizations
if ($IsWindows) {
    $LocalProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.local.ps1"
} else {
    $LocalProfile = "$env:HOME/.config/powershell/Microsoft.PowerShell_profile.local.ps1"
}
if (Test-Path $LocalProfile) { . $LocalProfile }
#endregion
