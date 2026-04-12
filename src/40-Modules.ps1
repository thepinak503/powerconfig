# PowerConfig Modules - Imports & Tool Init

# Terminal Icons
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# Zoxide
if (Get-Command zoxide -EA SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
}

# Starship
if (Get-Command starship -EA SilentlyContinue) {
    # Starship will be finalized in 70-Theme.ps1
}
