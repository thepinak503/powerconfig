Write-Host "=== PowerConfig Diagnostic ===" -ForegroundColor Cyan
Write-Host "PowerShell: $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"
Write-Host "Windows: $((Get-WindowsEditionInfo).Product)"
Write-Host "Arch: $env:DOTFILES_ARCH"
Write-Host "Admin: $((Get-PowerShellInfo).IsAdmin)"
Write-Host ""

Write-Host "=== Environment ===" -ForegroundColor Cyan
Write-Host "POWERCONFIG_DIR: $env:POWERCONFIG_DIR"
Write-Host "DOTFILES_OS: $env:DOTFILES_OS"
Write-Host "DOTFILES_DISTRO: $env:DOTFILES_DISTRO"
Write-Host "DOTFILES_ARCH: $env:DOTFILES_ARCH"
Write-Host "DOTFILES_PKG_MANAGER: $env:DOTFILES_PKG_MANAGER"
Write-Host "POWERCONFIG_MODE: $env:POWERCONFIG_MODE"
Write-Host "EDITOR: $global:EDITOR"
Write-Host ""

Write-Host "=== Path Check ===" -ForegroundColor Cyan
$env:Path -split ';' | Where-Object { $_ } | ForEach-Object { Write-Host "  $_" }
