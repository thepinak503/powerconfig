# PowerConfig

A modular PowerShell configuration suite focused on performance and domain-driven design.

## Installation

```powershell
irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install/install.ps1 | iex
```

## Structure

Modular architecture using a numbered loading sequence in the `src/` directory.

- `src/00-Init.ps1`: Performance tuning & initialization.
- `src/10-Environment.ps1`: Paths and Global variables.
- `src/20-Aliases.ps1`: Semantic alias grid (Git, Docker, K8s).
- `src/30-Standard.ps1`: UNIX utilities (sed, grep, head, etc).
- `src/50-MegaSuite.ps1`: Advanced tools for Net, Media, and Security.
- `src/70-Theme.ps1`: Starship & Tokyo Night integration.

## Key Features

- **Modular**: Bash-style sourcing for clean organization.
- **Fast**: Optimized for minimal startup delay.
- **Tools**: Integrated wrappers for FFmpeg, ImageMagick, and networking tasks.
- **Aliases**: Consistent shortcut logic for modern CLI tools.

## Documentation

Full command reference available via the local documentation site:
```powershell
Show-PowerDocs
```

---
[thepinak503/powerconfig](https://github.com/thepinak503/powerconfig)
