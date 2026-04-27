# PowerConfig

The Ultimate PowerShell Experience - Ultra config with all features.

## Install

```powershell
irm https://bit.ly/pc-install | iex
```

Or clone manually:
```powershell
git clone https://github.com/thepinak503/powerconfig.git $env:USERPROFILE\.powerconfig
. "$env:USERPROFILE\.powerconfig\Microsoft.PowerShell_profile.ps1"
```

## Structure

- `src/00-Functions.ps1` - All functions (no tiers!)
- `src/00-Aliases.ps1` - All aliases
- `Microsoft.PowerShell_profile.ps1` - Entry point

## Key Commands

| Command | Description |
|---------|-----------|
| `Show-Help` | Display all commands |
| `dottools` | Show tool status |
| `sysinfo` | System info (fastfetch) |
| `winutil` | Windows utility |
| `Update-PowerConfig` | Update config |

## Run Docs

```powershell
Show-PowerDocs
```

Or open `docs/index.html` in browser.