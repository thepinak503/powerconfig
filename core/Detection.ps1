$POWERCONFIG_IS_LAPTOP = $false
try {
    $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) { $POWERCONFIG_IS_LAPTOP = $true }
} catch {}

function global:Get-WindowsEditionInfo {
    $edition = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).EditionID
    $display = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).ProductName
    $ver = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).DisplayVersion
    $build = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue).CurrentBuild
    [PSCustomObject]@{
        Edition    = $edition
        Product    = $display
        Version    = $ver
        Build      = $build
        IsLaptop   = $POWERCONFIG_IS_LAPTOP
        IsServer   = if ($edition -match 'Server') { $true } else { $false }
    }
}

function global:Get-PowerShellInfo {
    [PSCustomObject]@{
        Edition        = $PSVersionTable.PSEdition
        Version        = $PSVersionTable.PSVersion
        OS             = $PSVersionTable.OS
        Platform       = $PSVersionTable.Platform
        Architecture   = $env:PROCESSOR_ARCHITECTURE
        IsAdmin        = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}

function global:Get-PackageManagers {
    $result = @{}
    if (Get-Command winget -ErrorAction SilentlyContinue) { $result['winget'] = $true }
    if (Get-Command scoop -ErrorAction SilentlyContinue) { $result['scoop'] = $true }
    if (Get-Command choco -ErrorAction SilentlyContinue) { $result['choco'] = $true }
    [PSCustomObject]$result
}

function Get-WindowsFeatures {
    Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Select-Object FeatureName, State
}
