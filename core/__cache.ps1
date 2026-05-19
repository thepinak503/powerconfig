$POWERCONFIG_CACHE_DIR = "$env:USERPROFILE\.config\powerconfig\cache"
$POWERCONFIG_CACHE_FILE = "$POWERCONFIG_CACHE_DIR\init.cache"

if (-not (Test-Path $POWERCONFIG_CACHE_DIR)) {
    New-Item -ItemType Directory -Path $POWERCONFIG_CACHE_DIR -Force | Out-Null
}

function _cache_load {
    if (Test-Path $POWERCONFIG_CACHE_FILE) {
        $data = Get-Content $POWERCONFIG_CACHE_FILE -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($data) {
            $env:DOTFILES_OS = $data.OS
            $env:DOTFILES_ARCH = $data.ARCH
            $env:DOTFILES_DISTRO = $data.DISTRO
            $env:DOTFILES_PKG_MANAGER = $data.PKG_MANAGER
            $env:DOTFILES_INIT = $data.INIT
            $env:POWERCONFIG_SHELL = $data.SHELL
            return $true
        }
    }
    return $false
}

function _cache_save {
    $data = @{
        OS = $env:DOTFILES_OS
        ARCH = $env:DOTFILES_ARCH
        DISTRO = $env:DOTFILES_DISTRO
        PKG_MANAGER = $env:DOTFILES_PKG_MANAGER
        INIT = $env:DOTFILES_INIT
        SHELL = $env:POWERCONFIG_SHELL
        TIMESTAMP = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
    $data | ConvertTo-Json | Set-Content $POWERCONFIG_CACHE_FILE
}

function _cache_gen {
    $os = if ($IsWindows -or $env:OS -match 'Windows') { 'Windows' } elseif ($IsLinux) { 'Linux' } elseif ($IsMacOS) { 'macOS' } else { 'Unknown' }
    $arch = $env:PROCESSOR_ARCHITECTURE
    if (-not $arch) { $arch = 'Unknown' }

    $distro = 'windows'
    if ($IsWindows) {
        $edition = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).EditionID
        if ($edition) { $distro = "windows-$edition" }
    }

    $pkg = 'none'
    if (Get-Command winget -ErrorAction SilentlyContinue) { $pkg = 'winget' }
    elseif (Get-Command scoop -ErrorAction SilentlyContinue) { $pkg = 'scoop' }
    elseif (Get-Command choco -ErrorAction SilentlyContinue) { $pkg = 'choco' }

    $init = if ($IsWindows) { 'windows' } else { 'unknown' }

    $shname = 'powershell'
    if ($PSVersionTable.PSEdition -eq 'Core') { $shname = 'pwsh' }

    $env:DOTFILES_OS = $os
    $env:DOTFILES_ARCH = $arch
    $env:DOTFILES_DISTRO = $distro
    $env:DOTFILES_PKG_MANAGER = $pkg
    $env:DOTFILES_INIT = $init
    $env:POWERCONFIG_SHELL = $shname

    _cache_save
}

if (-not (_cache_load)) {
    _cache_gen
    _cache_load
}
