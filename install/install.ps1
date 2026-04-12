#!/usr/bin/env pwsh
# PowerConfig Universal Installer
# Supports: Windows (PS 5.1+), Linux (PS 6+), macOS (PS 6+)
# Usage: 
#   Windows: iwr https://is.gd/powerconfig | iex
#   Unix:    curl -fsSL https://is.gd/powerconfig | pwsh -c -
#   Or:      pwsh -c "& {iwr https://is.gd/powerconfig | iex}"

[CmdletBinding()]
param(
    [ValidateSet("minimal", "standard", "advanced", "full")]
    [string]$Mode = "advanced",
    
    [switch]$Force,
    
    [ValidateSet("winget", "scoop", "choco", "brew", "apt", "dnf", "pacman", "zypper", "yum", "auto")]
    [string]$PreferredManager = "auto",
    
    [switch]$SkipDependencies,
    
    [switch]$SkipFonts,
    
    [switch]$NoColor,
    
    [switch]$Uninstall
)

## Cross-Platform Consideration: this installer is Windows-focused in this version.
if (-not $IsWindows) {
    Write-Host "PowerConfig installer is Windows-only in this version." -ForegroundColor Yellow
    exit 0
}

# Ensure TLS 1.2 for any remote downloads
if (-not ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

# Elevation: ensure the installer runs elevated on Windows
if ($IsWindows) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "Relaunching with elevated privileges..." -ForegroundColor Yellow
        Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Mode $Mode" -Verb RunAs
        exit
    }
}

#region ═══════════════════════════════════════════════════════════════════════
#                              INITIALIZATION
#═══════════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"  # Speed up web requests

# Version info
$InstallerVersion = "2.1.0"
$RepoUrl = "https://github.com/thepinak503/powerconfig"
$RepoRawUrl = "https://raw.githubusercontent.com/thepinak503/powerconfig/main"

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                           PLATFORM DETECTION
#═══════════════════════════════════════════════════════════════════════════════

# Detect PowerShell version
$script:PSVersionMajor = $PSVersionTable.PSVersion.Major
$script:IsLegacyPS = $script:PSVersionMajor -lt 6

# Detect OS - PS 5.x doesn't have automatic variables
if ($script:IsLegacyPS) {
    $script:OS = "Windows"
    $script:IsWin = $true
    $script:IsLnx = $false
    $script:IsMac = $false
} else {
    if ($IsWindows) {
        $script:OS = "Windows"
        $script:IsWin = $true
        $script:IsLnx = $false
        $script:IsMac = $false
    } elseif ($IsLinux) {
        $script:OS = "Linux"
        $script:IsWin = $false
        $script:IsLnx = $true
        $script:IsMac = $false
    } elseif ($IsMacOS) {
        $script:OS = "macOS"
        $script:IsWin = $false
        $script:IsLnx = $false
        $script:IsMac = $true
    } else {
        $script:OS = "Unknown"
        $script:IsWin = $false
        $script:IsLnx = $true  # Assume Unix-like
        $script:IsMac = $false
    }
}

# Detect Linux distribution
$script:LinuxDistro = $null
if ($script:IsLnx) {
    if (Test-Path "/etc/os-release") {
        $osRelease = Get-Content "/etc/os-release" -ErrorAction SilentlyContinue
        $idLine = $osRelease | Where-Object { $_ -match "^ID=" }
        if ($idLine) {
            $script:LinuxDistro = ($idLine -replace 'ID=|"', '').Trim().ToLower()
        }
    }
}

# Set paths based on OS
if ($script:IsWin) {
    $script:HomeDir = $env:USERPROFILE
    $script:ConfigDir = Join-Path $env:USERPROFILE ".config"
    $script:InstallDir = Join-Path $env:USERPROFILE ".powerconfig"
    $script:PathSep = "\"
    $script:IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} else {
    $script:HomeDir = $env:HOME
    $script:ConfigDir = Join-Path $env:HOME ".config"
    $script:InstallDir = Join-Path $env:HOME ".powerconfig"
    $script:PathSep = "/"
    $script:IsAdmin = (id -u) -eq 0
}

$script:BackupDir = Join-Path $script:HomeDir ".powerconfig-backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                              COLORS & OUTPUT
#═══════════════════════════════════════════════════════════════════════════════

# Check if terminal supports ANSI colors
function Test-AnsiSupport {
    if ($NoColor) { return $false }
    
    # Check common environment variables
    if ($env:NO_COLOR) { return $false }
    if ($env:TERM -eq "dumb") { return $false }
    
    # Windows legacy console check
    if ($script:IsWin -and $script:IsLegacyPS) {
        # Check if running in Windows Terminal, VS Code, or ConEmu
        if ($env:WT_SESSION -or $env:TERM_PROGRAM -eq "vscode" -or $env:ConEmuANSI -eq "ON") {
            return $true
        }
        # Check Windows 10 1511+ with VT support
        try {
            $build = [System.Environment]::OSVersion.Version.Build
            if ($build -ge 10586) {
                # Enable VT mode
                $null = [Console]::OutputEncoding
                return $true
            }
        } catch {}
        return $false
    }
    
    return $true
}

$script:UseAnsi = Test-AnsiSupport

# Define colors with fallback
if ($script:UseAnsi) {
    $ESC = [char]27
    $script:Colors = @{
        Red     = "$ESC[91m"
        Green   = "$ESC[92m"
        Yellow  = "$ESC[93m"
        Blue    = "$ESC[94m"
        Magenta = "$ESC[95m"
        Cyan    = "$ESC[96m"
        White   = "$ESC[97m"
        Gray    = "$ESC[90m"
        Bold    = "$ESC[1m"
        Reset   = "$ESC[0m"
    }
    $script:Symbols = @{
        Arrow   = "→"
        Check   = "✓"
        Cross   = "✗"
        Info    = "ℹ"
        Warn    = "⚠"
        Star    = "★"
        Dot     = "●"
    }
} else {
    $script:Colors = @{
        Red     = ""
        Green   = ""
        Yellow  = ""
        Blue    = ""
        Magenta = ""
        Cyan    = ""
        White   = ""
        Gray    = ""
        Bold    = ""
        Reset   = ""
    }
    $script:Symbols = @{
        Arrow   = "->"
        Check   = "[OK]"
        Cross   = "[X]"
        Info    = "[i]"
        Warn    = "[!]"
        Star    = "*"
        Dot     = "*"
    }
}

# Output functions
function Write-Step {
    param([string]$Message)
    Write-Host "$($Colors.Magenta)$($Symbols.Arrow)$($Colors.Reset) $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "$($Colors.Green)$($Symbols.Check)$($Colors.Reset) $Message"
}

function Write-Err {
    param([string]$Message)
    Write-Host "$($Colors.Red)$($Symbols.Cross)$($Colors.Reset) $Message"
}

function Write-Inf {
    param([string]$Message)
    Write-Host "$($Colors.Blue)$($Symbols.Info)$($Colors.Reset) $Message"
}

function Write-Wrn {
    param([string]$Message)
    Write-Host "$($Colors.Yellow)$($Symbols.Warn)$($Colors.Reset) $Message"
}

function Write-Banner {
    $c = $Colors
    $border = "$($c.Cyan)═" * 62 + $($c.Reset)
    
    Write-Host ""
    Write-Host "$($c.Cyan)╔$("═" * 62)╗$($c.Reset)"
    Write-Host "$($c.Cyan)║$($c.Reset)         $($c.Bold)$($c.White)POWERCONFIG UNIVERSAL INSTALLER$($c.Reset)                  $($c.Cyan)║$($c.Reset)"
    Write-Host "$($c.Cyan)║$($c.Reset)              $($c.Gray)Version $InstallerVersion$($c.Reset)                            $($c.Cyan)║$($c.Reset)"
    Write-Host "$($c.Cyan)║$($c.Reset)                                                              $($c.Cyan)║$($c.Reset)"
    Write-Host "$($c.Cyan)║$($c.Reset)  $($c.Blue)$RepoUrl$($c.Reset)   $($c.Cyan)║$($c.Reset)"
    Write-Host "$($c.Cyan)╚$("═" * 62)╝$($c.Reset)"
    Write-Host ""
}

function Write-SystemInfo {
    Write-Inf "System Information:"
    Write-Host "    $($Colors.Gray)OS:$($Colors.Reset)              $script:OS $(if ($script:LinuxDistro) { "($script:LinuxDistro)" })"
    Write-Host "    $($Colors.Gray)PowerShell:$($Colors.Reset)      $($PSVersionTable.PSVersion) $(if ($script:IsLegacyPS) { '(Legacy)' } else { '(Modern)' })"
    Write-Host "    $($Colors.Gray)Home:$($Colors.Reset)            $script:HomeDir"
    Write-Host "    $($Colors.Gray)Install Dir:$($Colors.Reset)     $script:InstallDir"
    Write-Host "    $($Colors.Gray)Admin/Root:$($Colors.Reset)      $(if ($script:IsAdmin) { 'Yes' } else { 'No' })"
    Write-Host ""
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                              UTILITY FUNCTIONS
#═══════════════════════════════════════════════════════════════════════════════

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Invoke-SafeCommand {
    param(
        [scriptblock]$ScriptBlock,
        [string]$ErrorMessage = "Command failed"
    )
    try {
        & $ScriptBlock
        return $true
    } catch {
        Write-Err "$ErrorMessage : $_"
        return $false
    }
}

function Refresh-EnvironmentPath {
    if ($script:IsWin) {
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"
        
        # Also refresh for scoop
        $scoopShims = Join-Path $env:USERPROFILE "scoop\shims"
        if ((Test-Path $scoopShims) -and ($env:Path -notlike "*$scoopShims*")) {
            $env:Path = "$scoopShims;$env:Path"
        }
    } else {
        # Source common profile files
        $profilePaths = @(
            "/etc/profile",
            "$env:HOME/.profile",
            "$env:HOME/.bashrc",
            "$env:HOME/.zshrc"
        )
        foreach ($p in $profilePaths) {
            if (Test-Path $p) {
                # Parse PATH exports
                $content = Get-Content $p -ErrorAction SilentlyContinue
                $pathLines = $content | Where-Object { $_ -match 'export\s+PATH' }
                # This is simplified - full PATH refresh on Unix is complex
            }
        }
        
        # Add common paths
        $commonPaths = @(
            "/usr/local/bin",
            "/opt/homebrew/bin",
            "$env:HOME/.local/bin",
            "$env:HOME/bin",
            "$env:HOME/.cargo/bin"
        )
        foreach ($p in $commonPaths) {
            if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
                $env:PATH = "${p}:$env:PATH"
            }
        }
    }
}

function Get-UserConfirmation {
    param(
        [string]$Message,
        [bool]$Default = $false
    )
    $defaultHint = if ($Default) { "[Y/n]" } else { "[y/N]" }
    $response = Read-Host "$Message $defaultHint"
    
    if ([string]::IsNullOrWhiteSpace($response)) {
        return $Default
    }
    return $response -match '^[yY]'
}

function Invoke-WithSudo {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    
    if ($script:IsWin) {
        # Windows - would need elevation, just run directly
        & $Command @Arguments
    } else {
        if ($script:IsAdmin) {
            & $Command @Arguments
        } else {
            if (Test-CommandExists "sudo") {
                sudo $Command @Arguments
            } else {
                Write-Wrn "sudo not found, trying without elevation..."
                & $Command @Arguments
            }
        }
    }
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                           PACKAGE MANAGER HANDLING
#═══════════════════════════════════════════════════════════════════════════════

function Get-AvailablePackageManagers {
    $managers = [ordered]@{}
    
    if ($script:IsWin) {
        # Windows package managers
        if (Test-CommandExists "winget") {
            $managers["winget"] = @{
                Available = $true
                Version = try { (winget --version) } catch { "unknown" }
            }
        }
        if (Test-CommandExists "scoop") {
            $managers["scoop"] = @{
                Available = $true
                Version = try { (scoop --version | Select-Object -First 1) } catch { "unknown" }
            }
        }
        if (Test-CommandExists "choco") {
            $managers["choco"] = @{
                Available = $true
                Version = try { (choco --version) } catch { "unknown" }
            }
        }
    }
    
    if ($script:IsMac) {
        if (Test-CommandExists "brew") {
            $managers["brew"] = @{
                Available = $true
                Version = try { (brew --version | Select-Object -First 1) } catch { "unknown" }
            }
        }
    }
    
    if ($script:IsLnx -or $script:IsMac) {
        # Linux package managers
        $linuxManagers = @("apt", "apt-get", "dnf", "yum", "pacman", "zypper", "apk", "brew")
        foreach ($mgr in $linuxManagers) {
            if (Test-CommandExists $mgr) {
                $managers[$mgr] = @{
                    Available = $true
                    Version = "system"
                }
            }
        }
    }
    
    return $managers
}

function Select-PackageManager {
    param(
        [hashtable]$Available,
        [string]$Preferred
    )
    
    if ($Preferred -ne "auto" -and $Available.Contains($Preferred)) {
        return $Preferred
    }
    
    # Priority order based on OS
    $priority = if ($script:IsWin) {
        @("winget", "scoop", "choco")
    } elseif ($script:IsMac) {
        @("brew")
    } else {
        # Linux - prefer based on distro
        switch ($script:LinuxDistro) {
            { $_ -in @("ubuntu", "debian", "linuxmint", "pop", "elementary") } { @("apt", "apt-get") }
            { $_ -in @("fedora", "rhel", "centos", "rocky", "alma") } { @("dnf", "yum") }
            { $_ -in @("arch", "manjaro", "endeavouros") } { @("pacman") }
            { $_ -in @("opensuse", "suse") } { @("zypper") }
            { $_ -in @("alpine") } { @("apk") }
            default { @("apt", "apt-get", "dnf", "yum", "pacman", "zypper", "apk") }
        }
    }
    
    foreach ($mgr in $priority) {
        if ($Available.Contains($mgr)) {
            return $mgr
        }
    }
    
    return $null
}

function Install-PackageManagerScoop {
    Write-Step "Installing Scoop package manager..."
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
        [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $response = Invoke-WebRequest -Uri 'https://get.scoop.sh' -UseBasicParsing
        Invoke-Expression $response.Content
        
        Refresh-EnvironmentPath
        
        if (Test-CommandExists "scoop") {
            Write-Ok "Scoop installed successfully"
            return $true
        }
    } catch {
        Write-Err "Failed to install Scoop: $_"
    }
    return $false
}

function Install-PackageManagerChocolatey {
    Write-Step "Installing Chocolatey package manager..."
    
    if (-not $script:IsAdmin) {
        Write-Wrn "Chocolatey requires administrator privileges"
        Write-Inf "Please run PowerShell as Administrator and try again"
        return $false
    }
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $response = Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -UseBasicParsing
        Invoke-Expression $response.Content
        
        Refresh-EnvironmentPath
        
        if (Test-CommandExists "choco") {
            Write-Ok "Chocolatey installed successfully"
            return $true
        }
    } catch {
        Write-Err "Failed to install Chocolatey: $_"
    }
    return $false
}

function Install-PackageManagerHomebrew {
    Write-Step "Installing Homebrew package manager..."
    try {
        $installScript = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        
        if ($script:IsMac) {
            bash -c $installScript
        } else {
            # Linux Homebrew
            Invoke-WithSudo "bash" @("-c", $installScript)
        }
        
        Refresh-EnvironmentPath
        
        # Add brew to path for this session
        if ($script:IsMac) {
            $brewPath = "/opt/homebrew/bin/brew"
            if (-not (Test-Path $brewPath)) {
                $brewPath = "/usr/local/bin/brew"
            }
        } else {
            $brewPath = "/home/linuxbrew/.linuxbrew/bin/brew"
            if (-not (Test-Path $brewPath)) {
                $brewPath = "$env:HOME/.linuxbrew/bin/brew"
            }
        }
        
        if (Test-Path $brewPath) {
            $env:PATH = "$(Split-Path $brewPath):$env:PATH"
            Write-Ok "Homebrew installed successfully"
            return $true
        }
    } catch {
        Write-Err "Failed to install Homebrew: $_"
    }
    return $false
}

function Install-Package {
    param(
        [string]$Manager,
        [string]$PackageName,
        [string]$WingetId = $null,
        [string]$ScoopName = $null,
        [string]$ChocoName = $null,
        [string]$BrewName = $null,
        [string]$AptName = $null,
        [string]$DnfName = $null,
        [string]$PacmanName = $null,
        [switch]$Silent
    )
    
    $name = switch ($Manager) {
        "winget" { if ($WingetId) { $WingetId } else { $PackageName } }
        "scoop" { if ($ScoopName) { $ScoopName } else { $PackageName } }
        "choco" { if ($ChocoName) { $ChocoName } else { $PackageName } }
        "brew" { if ($BrewName) { $BrewName } else { $PackageName } }
        "apt" { if ($AptName) { $AptName } else { $PackageName } }
        "apt-get" { if ($AptName) { $AptName } else { $PackageName } }
        "dnf" { if ($DnfName) { $DnfName } else { $PackageName } }
        "yum" { if ($DnfName) { $DnfName } else { $PackageName } }
        "pacman" { if ($PacmanName) { $PacmanName } else { $PackageName } }
        default { $PackageName }
    }
    
    if (-not $name -or $name -eq "-") {
        return $true  # Skip if no package name for this manager
    }
    
    if (-not $Silent) {
        Write-Inf "  Installing $PackageName..."
    }
    
    $result = $false
    $output = $null
    
    try {
        switch ($Manager) {
            "winget" {
                $output = winget install --id $name --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1
                $result = $LASTEXITCODE -eq 0 -or $output -match "already installed"
            }
            "scoop" {
                $output = scoop install $name 2>&1
                $result = $LASTEXITCODE -eq 0 -or $output -match "already installed"
            }
            "choco" {
                $output = choco install $name -y --no-progress 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "brew" {
                $output = brew install $name 2>&1
                $result = $LASTEXITCODE -eq 0 -or $output -match "already installed"
            }
            "apt" {
                $output = Invoke-WithSudo "apt" @("install", "-y", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "apt-get" {
                $output = Invoke-WithSudo "apt-get" @("install", "-y", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "dnf" {
                $output = Invoke-WithSudo "dnf" @("install", "-y", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "yum" {
                $output = Invoke-WithSudo "yum" @("install", "-y", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "pacman" {
                $output = Invoke-WithSudo "pacman" @("-S", "--noconfirm", "--needed", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "zypper" {
                $output = Invoke-WithSudo "zypper" @("install", "-y", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
            "apk" {
                $output = Invoke-WithSudo "apk" @("add", $name) 2>&1
                $result = $LASTEXITCODE -eq 0
            }
        }
    } catch {
        $result = $false
    }
    
    return $result
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                              GIT INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════

function Install-Git {
    param([string]$Manager)
    
    Write-Step "Installing Git via $Manager..."
    
    $result = Install-Package -Manager $Manager -PackageName "git" `
        -WingetId "Git.Git" `
        -ScoopName "git" `
        -ChocoName "git" `
        -BrewName "git" `
        -AptName "git" `
        -DnfName "git" `
        -PacmanName "git"
    
    Refresh-EnvironmentPath
    
    if (Test-CommandExists "git") {
        Write-Ok "Git installed successfully"
        return $true
    }
    
    Write-Err "Git installation may require terminal restart"
    return $false
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                           DEPENDENCY INSTALLATION
#═══════════════════════════════════════════════════════════════════════════════

function Get-DependencyList {
    param([string]$Mode)
    
    # Core dependencies (always installed)
    $core = @(
        @{
            Name = "fzf"
            Description = "Fuzzy finder"
            WingetId = "junegunn.fzf"
            Scoop = "fzf"
            Choco = "fzf"
            Brew = "fzf"
            Apt = "fzf"
            Dnf = "fzf"
            Pacman = "fzf"
        },
        @{
            Name = "zoxide"
            Description = "Smarter cd command"
            WingetId = "ajeetdsouza.zoxide"
            Scoop = "zoxide"
            Choco = "zoxide"
            Brew = "zoxide"
            Apt = "-"  # Not in default repos
            Dnf = "-"
            Pacman = "zoxide"
        },
        @{
            Name = "starship"
            Description = "Cross-shell prompt"
            WingetId = "Starship.Starship"
            Scoop = "starship"
            Choco = "starship"
            Brew = "starship"
            Apt = "-"
            Dnf = "-"
            Pacman = "starship"
        }
    )
    
    # Standard dependencies
    $standard = @(
        @{
            Name = "eza"
            Description = "Modern ls replacement"
            WingetId = "eza-community.eza"
            Scoop = "eza"
            Choco = "eza"
            Brew = "eza"
            Apt = "-"
            Dnf = "-"
            Pacman = "eza"
        },
        @{
            Name = "bat"
            Description = "Cat with syntax highlighting"
            WingetId = "sharkdp.bat"
            Scoop = "bat"
            Choco = "bat"
            Brew = "bat"
            Apt = "bat"
            Dnf = "bat"
            Pacman = "bat"
        },
        @{
            Name = "ripgrep"
            Description = "Fast grep alternative"
            WingetId = "BurntSushi.ripgrep.MSVC"
            Scoop = "ripgrep"
            Choco = "ripgrep"
            Brew = "ripgrep"
            Apt = "ripgrep"
            Dnf = "ripgrep"
            Pacman = "ripgrep"
        },
        @{
            Name = "fd"
            Description = "Fast find alternative"
            WingetId = "sharkdp.fd"
            Scoop = "fd"
            Choco = "fd"
            Brew = "fd"
            Apt = "fd-find"
            Dnf = "fd-find"
            Pacman = "fd"
        }
    )
    
    # Advanced dependencies
    $advanced = @(
        @{
            Name = "delta"
            Description = "Better git diff"
            WingetId = "dandavison.delta"
            Scoop = "delta"
            Choco = "delta"
            Brew = "git-delta"
            Apt = "-"
            Dnf = "-"
            Pacman = "git-delta"
        },
        @{
            Name = "gh"
            Description = "GitHub CLI"
            WingetId = "GitHub.cli"
            Scoop = "gh"
            Choco = "gh"
            Brew = "gh"
            Apt = "gh"
            Dnf = "gh"
            Pacman = "github-cli"
        },
        @{
            Name = "lazygit"
            Description = "Git TUI"
            WingetId = "JesseDuffield.lazygit"
            Scoop = "lazygit"
            Choco = "lazygit"
            Brew = "lazygit"
            Apt = "-"
            Dnf = "-"
            Pacman = "lazygit"
        },
        @{
            Name = "neovim"
            Description = "Modern vim"
            WingetId = "Neovim.Neovim"
            Scoop = "neovim"
            Choco = "neovim"
            Brew = "neovim"
            Apt = "neovim"
            Dnf = "neovim"
            Pacman = "neovim"
        },
        @{
            Name = "fastfetch"
            Description = "System info display"
            WingetId = "Fastfetch-cli.Fastfetch"
            Scoop = "fastfetch"
            Choco = "fastfetch"
            Brew = "fastfetch"
            Apt = "-"
            Dnf = "fastfetch"
            Pacman = "fastfetch"
        }
    )
    
    # Full dependencies
    $full = @(
        @{
            Name = "bottom"
            Description = "System monitor"
            WingetId = "Clement.bottom"
            Scoop = "bottom"
            Choco = "bottom"
            Brew = "bottom"
            Apt = "-"
            Dnf = "-"
            Pacman = "bottom"
        },
        @{
            Name = "dust"
            Description = "Disk usage analyzer"
            WingetId = "bootandy.dust"
            Scoop = "dust"
            Choco = "dust"
            Brew = "dust"
            Apt = "-"
            Dnf = "-"
            Pacman = "dust"
        },
        @{
            Name = "duf"
            Description = "Disk usage/free"
            WingetId = "muesli.duf"
            Scoop = "duf"
            Choco = "duf"
            Brew = "duf"
            Apt = "duf"
            Dnf = "duf"
            Pacman = "duf"
        },
        @{
            Name = "procs"
            Description = "Modern ps replacement"
            WingetId = "dalance.procs"
            Scoop = "procs"
            Choco = "procs"
            Brew = "procs"
            Apt = "-"
            Dnf = "-"
            Pacman = "procs"
        },
        @{
            Name = "hyperfine"
            Description = "Benchmarking tool"
            WingetId = "sharkdp.hyperfine"
            Scoop = "hyperfine"
            Choco = "hyperfine"
            Brew = "hyperfine"
            Apt = "hyperfine"
            Dnf = "-"
            Pacman = "hyperfine"
        },
        @{
            Name = "tokei"
            Description = "Code statistics"
            WingetId = "XAMPPRocky.Tokei"
            Scoop = "tokei"
            Choco = "tokei"
            Brew = "tokei"
            Apt = "tokei"
            Dnf = "tokei"
            Pacman = "tokei"
        },
        @{
            Name = "onefetch"
            Description = "Git repo info"
            WingetId = "o2sh.onefetch"
            Scoop = "onefetch"
            Choco = "onefetch"
            Brew = "onefetch"
            Apt = "-"
            Dnf = "-"
            Pacman = "onefetch"
        },
        @{
            Name = "tldr"
            Description = "Simplified man pages"
            WingetId = "tldr-pages.tlrc"
            Scoop = "tlrc"
            Choco = "tldr"
            Brew = "tlrc"
            Apt = "tldr"
            Dnf = "tldr"
            Pacman = "tldr"
        }
    )
    
    switch ($Mode) {
        "minimal" { return $core }
        "standard" { return $core + $standard }
        "advanced" { return $core + $standard + $advanced }
        "full" { return $core + $standard + $advanced + $full }
        default { return $core + $standard + $advanced }
    }
}

function Install-Dependencies {
    param(
        [string]$Manager,
        [string]$Mode
    )
    
    if (-not $Manager) {
        Write-Wrn "No package manager available - skipping dependencies"
        return
    }
    
    Write-Step "Installing dependencies ($Mode mode) via $Manager..."
    
    # Set up package manager buckets/repos
    switch ($Manager) {
        "scoop" {
            Write-Inf "  Setting up Scoop buckets..."
            scoop bucket add main 2>&1 | Out-Null
            scoop bucket add extras 2>&1 | Out-Null
        }
        "apt" {
            Write-Inf "  Updating package lists..."
            Invoke-WithSudo "apt" @("update") 2>&1 | Out-Null
        }
        "apt-get" {
            Write-Inf "  Updating package lists..."
            Invoke-WithSudo "apt-get" @("update") 2>&1 | Out-Null
        }
        "dnf" {
            # DNF auto-updates
        }
        "pacman" {
            Write-Inf "  Updating package database..."
            Invoke-WithSudo "pacman" @("-Sy") 2>&1 | Out-Null
        }
    }
    
    $deps = Get-DependencyList -Mode $Mode
    $installed = 0
    $failed = 0
    
    foreach ($dep in $deps) {
        $pkgName = switch ($Manager) {
            "winget" { $dep.WingetId }
            "scoop" { $dep.Scoop }
            "choco" { $dep.Choco }
            "brew" { $dep.Brew }
            { $_ -in @("apt", "apt-get") } { $dep.Apt }
            { $_ -in @("dnf", "yum") } { $dep.Dnf }
            "pacman" { $dep.Pacman }
            default { $dep.Name }
        }
        
        if (-not $pkgName -or $pkgName -eq "-") {
            Write-Host "    $($Colors.Gray)Skipping $($dep.Name) (not available)$($Colors.Reset)"
            continue
        }
        
        Write-Host "    $($Colors.Blue)$($Symbols.Dot)$($Colors.Reset) $($dep.Name) - $($dep.Description)"
        
        $result = Install-Package -Manager $Manager -PackageName $pkgName -Silent
        
        if ($result) {
            $installed++
        } else {
            $failed++
        }
    }
    
    Refresh-EnvironmentPath
    Write-Ok "Dependencies: $installed installed, $failed skipped/failed"
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                              CONFIGURATION
#═══════════════════════════════════════════════════════════════════════════════

function Backup-ExistingConfig {
    $backedUp = $false
    
    if (Test-Path $PROFILE) {
        if (-not (Test-Path $script:BackupDir)) {
            New-Item -ItemType Directory -Path $script:BackupDir -Force | Out-Null
        }
        Copy-Item -Path $PROFILE -Destination (Join-Path $script:BackupDir "profile.ps1") -Force
        $backedUp = $true
        Write-Inf "Backed up profile to $script:BackupDir"
    }
    
    $starshipConfig = Join-Path $script:ConfigDir "starship.toml"
    if (Test-Path $starshipConfig) {
        if (-not (Test-Path $script:BackupDir)) {
            New-Item -ItemType Directory -Path $script:BackupDir -Force | Out-Null
        }
        Copy-Item -Path $starshipConfig -Destination (Join-Path $script:BackupDir "starship.toml") -Force
        $backedUp = $true
        Write-Inf "Backed up starship config to $script:BackupDir"
    }
    
    return $backedUp
}

function Install-PowerConfig {
    if (Test-Path $script:InstallDir) {
        if (-not $Force) {
            Write-Wrn "PowerConfig already exists at $script:InstallDir"
            if (-not (Get-UserConfirmation "Reinstall?" $false)) {
                return $true  # Continue with existing
            }
        }
        Write-Step "Removing existing installation..."
        Remove-Item -Path $script:InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Step "Cloning PowerConfig repository..."
    
    $gitArgs = @("clone", "--depth=1", $RepoUrl, $script:InstallDir)
    $output = & git @gitArgs 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Failed to clone repository"
        Write-Host $output
        return $false
    }
    
    Write-Ok "PowerConfig installed to $script:InstallDir"
    return $true
}

function Install-StarshipConfig {
    $sourceConfig = Join-Path $script:InstallDir "apps/starship/starship.toml"
    $targetConfig = Join-Path $script:ConfigDir "starship.toml"
    
    # Create config directory
    if (-not (Test-Path $script:ConfigDir)) {
        New-Item -ItemType Directory -Path $script:ConfigDir -Force | Out-Null
    }
    
    if (-not (Test-Path $sourceConfig)) {
        Write-Wrn "Starship config not found in repository"
        return
    }
    
    # Remove existing
    if (Test-Path $targetConfig) {
        Remove-Item $targetConfig -Force -ErrorAction SilentlyContinue
    }
    
    # Create symlink or copy
    try {
        if ($script:IsWin) {
            # Try native PowerShell symlink first
            New-Item -ItemType SymbolicLink -Path $targetConfig -Target $sourceConfig -Force -ErrorAction Stop | Out-Null
        } else {
            & ln -sf $sourceConfig $targetConfig 2>&1 | Out-Null
        }
        Write-Ok "Starship config linked"
    } catch {
        # Fall back to copy
        Copy-Item $sourceConfig $targetConfig -Force
        Write-Ok "Starship config copied (symlink failed)"
    }
}

function Install-FastfetchConfig {
    $sourceConfig = Join-Path $script:InstallDir "apps/fastfetch/config.jsonc"
    $targetConfig = Join-Path $script:ConfigDir "fastfetch/config.jsonc"
    
    # Create fastfetch config directory
    $fastfetchDir = Join-Path $script:ConfigDir "fastfetch"
    if (-not (Test-Path $fastfetchDir)) {
        New-Item -ItemType Directory -Path $fastfetchDir -Force | Out-Null
    }
    
    if (-not (Test-Path $sourceConfig)) {
        Write-Wrn "Fastfetch config not found in repository"
        return
    }
    
    # Create symlink or copy
    try {
        if ($script:IsWin) {
            New-Item -ItemType SymbolicLink -Path $targetConfig -Target $sourceConfig -Force -ErrorAction Stop | Out-Null
        } else {
            & ln -sf $sourceConfig $targetConfig 2>&1 | Out-Null
        }
        Write-Ok "Fastfetch config linked"
    } catch {
        Copy-Item $sourceConfig $targetConfig -Force
        Write-Ok "Fastfetch config copied (symlink failed)"
    }
}

function Install-PowerShellProfile {
    $profileDir = Split-Path $PROFILE -Parent
    
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    $mainProfile = Join-Path $script:InstallDir "shells/powershell/profile.ps1"
    $starshipConfig = Join-Path $script:ConfigDir "starship.toml"
    
    # Escape paths for string
    $escapedInstallDir = $script:InstallDir -replace '\\', '\\'
    $escapedMainProfile = $mainProfile -replace '\\', '\\'
    $escapedStarshipConfig = $starshipConfig -replace '\\', '\\'
    
    $profileContent = @"
# ═══════════════════════════════════════════════════════════════════════════════
#                              POWERCONFIG PROFILE
#                    Generated by PowerConfig Installer v$InstallerVersion
# ═══════════════════════════════════════════════════════════════════════════════

# Configuration
`$env:POWERCONFIG_MODE = "$Mode"
`$env:POWERCONFIG_DIR = "$escapedInstallDir"
`$env:STARSHIP_CONFIG = "$escapedStarshipConfig"

# Load main profile
`$powerConfigProfile = "$escapedMainProfile"
if (Test-Path `$powerConfigProfile) {
    . `$powerConfigProfile
} else {
    Write-Warning "PowerConfig profile not found at: `$powerConfigProfile"
    Write-Warning "Run the installer again or check your installation."
}
"@
    
    Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8
    Write-Ok "PowerShell profile created at $PROFILE"
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                              UNINSTALLATION
#═══════════════════════════════════════════════════════════════════════════════

function Invoke-Uninstall {
    Write-Banner
    Write-Step "Uninstalling PowerConfig..."
    
    # Remove installation directory
    if (Test-Path $script:InstallDir) {
        Remove-Item -Path $script:InstallDir -Recurse -Force
        Write-Ok "Removed $script:InstallDir"
    }
    
    # Remove profile (but backup first)
    if (Test-Path $PROFILE) {
        $backupPath = "$PROFILE.bak"
        Copy-Item $PROFILE $backupPath -Force
        Remove-Item $PROFILE -Force
        Write-Ok "Removed profile (backed up to $backupPath)"
    }
    
    # Remove starship config if it's a link to our config
    $starshipConfig = Join-Path $script:ConfigDir "starship.toml"
    if (Test-Path $starshipConfig) {
        $item = Get-Item $starshipConfig -Force
        if ($item.LinkType -eq "SymbolicLink" -and $item.Target -like "*powerconfig*") {
            Remove-Item $starshipConfig -Force
            Write-Ok "Removed Starship config link"
        }
    }
    
    Write-Host ""
    Write-Ok "PowerConfig uninstalled successfully!"
    Write-Inf "Your backup profiles may still exist in $script:HomeDir"
}

#endregion

#region ═══════════════════════════════════════════════════════════════════════
#                                   MAIN
#═══════════════════════════════════════════════════════════════════════════════

function Main {
    # Handle uninstall
    if ($Uninstall) {
        Invoke-Uninstall
        return
    }
    
    Write-Banner
    Write-SystemInfo
    
    # Check PowerShell version
    if ($script:PSVersionMajor -lt 5) {
        Write-Err "PowerShell 5.0 or higher is required"
        Write-Inf "Current version: $($PSVersionTable.PSVersion)"
        exit 1
    }
    
    # Check for Git
    $manager = $null
    
    if (-not (Test-CommandExists "git")) {
        Write-Wrn "Git not found"
        
        $available = Get-AvailablePackageManagers
        
        if ($available.Count -eq 0) {
            Write-Step "No package manager found. Installing one..."
            
            if ($script:IsWin) {
                # Try scoop first (doesn't require admin)
                if (Install-PackageManagerScoop) {
                    $available = Get-AvailablePackageManagers
                } elseif ($script:IsAdmin) {
                    if (Install-PackageManagerChocolatey) {
                        $available = Get-AvailablePackageManagers
                    }
                }
            } elseif ($script:IsMac -or $script:IsLnx) {
                if (Install-PackageManagerHomebrew) {
                    $available = Get-AvailablePackageManagers
                }
            }
        }
        
        if ($available.Count -gt 0) {
            Write-Inf "Available package managers:"
            foreach ($mgr in $available.Keys) {
                Write-Host "    $($Colors.Green)$($Symbols.Check)$($Colors.Reset) $mgr"
            }
        }
        
        $manager = Select-PackageManager -Available $available -Preferred $PreferredManager
        
        if ($manager) {
            $gitInstalled = Install-Git -Manager $manager
            if (-not $gitInstalled -and -not (Test-CommandExists "git")) {
                Write-Err "Git installation failed"
                Write-Inf "Please install Git manually and run the installer again"
                Write-Inf "  Windows: https://git-scm.com/download/win"
                Write-Inf "  macOS:   brew install git"
                Write-Inf "  Linux:   Use your package manager (apt, dnf, pacman, etc.)"
                exit 1
            }
        } else {
            Write-Err "No package manager available to install Git"
            exit 1
        }
    } else {
        $gitVersion = (git --version) -replace 'git version ', ''
        Write-Ok "Git found: $gitVersion"
        
        $available = Get-AvailablePackageManagers
        $manager = Select-PackageManager -Available $available -Preferred $PreferredManager
    }
    
    if ($manager) {
        Write-Ok "Using package manager: $manager"
    }
    
    Write-Host ""
    
    # Backup existing configuration
    Backup-ExistingConfig
    
    # Install PowerConfig
    $installed = Install-PowerConfig
    if (-not $installed) {
        if (-not (Get-UserConfirmation "Installation failed. Continue anyway?" $false)) {
            exit 1
        }
    }
    
    Write-Host ""
    
    # Install dependencies
    if (-not $SkipDependencies -and $manager) {
        Install-Dependencies -Manager $manager -Mode $Mode
    } elseif ($SkipDependencies) {
        Write-Inf "Skipping dependency installation (--SkipDependencies)"
    }
    
    Write-Host ""
    
    # Configure starship
    Install-StarshipConfig

    # Configure fastfetch
    Install-FastfetchConfig
    
    # Create profile
    Install-PowerShellProfile
    
    # Final message
    Write-Host ""
    Write-Host "$($Colors.Green)$("═" * 62)$($Colors.Reset)"
    Write-Ok "$($Colors.Bold)Installation Complete!$($Colors.Reset)"
    Write-Host "$($Colors.Green)$("═" * 62)$($Colors.Reset)"
    Write-Host ""
    Write-Inf "To activate PowerConfig, either:"
    Write-Host "    $($Colors.Cyan)1.$($Colors.Reset) Restart your terminal"
    Write-Host "    $($Colors.Cyan)2.$($Colors.Reset) Run: $($Colors.Yellow). `$PROFILE$($Colors.Reset)"
    Write-Host ""
    Write-Inf "Configuration:"
    Write-Host "    $($Colors.Gray)Mode:$($Colors.Reset)        $Mode"
    Write-Host "    $($Colors.Gray)Install Dir:$($Colors.Reset) $script:InstallDir"
    Write-Host "    $($Colors.Gray)Profile:$($Colors.Reset)     $PROFILE"
    Write-Host "    $($Colors.Gray)Backup:$($Colors.Reset)      $script:BackupDir"
    Write-Host ""
    Write-Inf "Commands:"
    Write-Host "    $($Colors.Gray)Reinstall:$($Colors.Reset)   iwr $RepoUrl/install.ps1 | iex"
    Write-Host "    $($Colors.Gray)Uninstall:$($Colors.Reset)   pwsh -c `"iwr $RepoUrl/install.ps1 | iex`" -Uninstall"
    Write-Host ""
}

# Run main
Main

#endregion
