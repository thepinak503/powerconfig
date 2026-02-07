# ⚡ PowerConfig

**The Ultimate PowerShell Configuration**

PowerConfig is a comprehensive, modular PowerShell configuration designed for Windows power users. It features extensive aliases, functions, and integrations with modern CLI tools, along with full support for Windows package managers: **Scoop**, **Chocolatey**, and **Winget**.

[![GitHub stars](https://img.shields.io/github/stars/thepinak503/powerconfig?style=flat-square)](https://github.com/thepinak503/powerconfig/stargazers)
[![License](https://img.shields.io/github/license/thepinak503/powerconfig?style=flat-square)](LICENSE)

## ✨ Features

### 🪟 Windows-First Design
- Native Windows commands and utilities
- Windows Terminal integration
- Control Panel shortcuts
- Administrative tools access
- System functions and automation

### 📦 Package Manager Support
- **Scoop**: Modern, fast Windows package manager
- **Chocolatey**: The most popular Windows package manager
- **Winget**: Microsoft's official Windows Package Manager
- Universal aliases that work with any manager

### 🛠️ Development Ready
- **Python**: pip, poetry, conda support
- **Node.js**: npm, yarn, pnpm support
- **Rust**: Cargo integration
- **Go**: Full Go toolchain support
- **Docker**: Complete Docker/Docker Compose aliases
- **Kubernetes**: kubectl and Helm shortcuts
- **Terraform**: Infrastructure as code
- **AWS/Azure/GCP**: Cloud provider integration

### 🔧 Modern Tools
- **Starship**: Cross-shell prompt
- **FZF**: Fuzzy finder with PowerShell keybindings
- **Zoxide**: Smart directory jumping
- **Eza**: Modern `ls` replacement
- **Bat**: Syntax-highlighting cat
- **Ripgrep**: Lightning-fast grep
- **Delta**: Beautiful git diffs
- **Dust**: Modern `du` replacement

### 🎯 Three Configuration Modes
- **Basic**: Essential aliases, minimal setup
- **Advanced**: Full aliases, modern tools (default)
- **Ultra-Nerd**: Everything + maximum features

## 🚀 Installation

### Quick Install (One Command)

```powershell
# Using PowerShell 5.1 or PowerShell Core
irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install.ps1 | iex
```

### Manual Installation

```powershell
# Clone the repository
git clone https://github.com/thepinak503/powerconfig.git $env:USERPROFILE\.powerconfig

# Run the installer
& $env:USERPROFILE\.powerconfig\install.ps1
```

### Prerequisites

- PowerShell 5.1 or PowerShell Core 7.0+
- Git
- Windows 10/11 (also works on Windows Server)

## 📁 Structure

```
%USERPROFILE%\.powerconfig\
├── Microsoft.PowerShell_profile.ps1  # Main entry point
├── install.ps1                       # One-command installer
├── README.md
├── LICENSE
│
├── Modules/                          # PowerShell modules
│   ├── Aliases.ps1                  # Core aliases
│   ├── Functions.ps1                # Utility functions
│   ├── PackageManagers.ps1          # Scoop/Choco/Winget
│   ├── Development.ps1              # Dev tools support
│   ├── ModernTools.ps1              # Modern CLI tools
│   └── Windows.ps1                  # Windows-specific
│
└── Themes/                          # Custom themes (optional)
```

## 📚 Package Manager Aliases

### Scoop
```powershell
s              # scoop
si <package>   # scoop install
sun <package>  # scoop uninstall
su             # scoop update
sup            # scoop update *
ss <query>     # scoop search
sls            # scoop list
sc             # scoop cleanup *
```

### Chocolatey
```powershell
ch             # choco
chi <package>  # choco install
chun <package> # choco uninstall
chup <package> # choco upgrade
cha            # choco upgrade all
chs <query>    # choco search
chls           # choco list --local-only
```

### Winget
```powershell
w              # winget
wi <package>   # winget install
wun <package>  # winget uninstall
wup <package>  # winget upgrade
wua            # winget upgrade --all
ws <query>     # winget search
wls            # winget list
```

### Universal
```powershell
pinstall <package>   # Install using any available manager
psearch <query>      # Search across all managers
pupdate              # Update all packages
```

## 🐙 Git Aliases

```powershell
g              # git
gs             # git status -sb
ga             # git add
gaa            # git add --all
gc             # git commit
gcm "msg"      # git commit -m "msg"
gco            # git checkout
gcb            # git checkout -b
gd             # git diff
gds            # git diff --staged
gf             # git fetch
gfa            # git fetch --all
gp             # git push
gpl            # git pull
lazyg "msg"    # git add . && git commit -m "msg" && git push
```

## 🐳 Docker Aliases

```powershell
d              # docker
dc             # docker-compose
dps            # docker ps (formatted)
dpa            # docker ps -a
di             # docker images
dex <name>     # docker exec -it
dr <image>     # docker run -it --rm
dprune         # Clean up Docker
```

## ☸️ Kubernetes Aliases

```powershell
k              # kubectl
kg             # kubectl get
kd             # kubectl describe
kl             # kubectl logs
kgp            # kubectl get pods
kgd            # kubectl get deployment
h              # helm
hin            # helm install
hup            # helm upgrade
```

## 🧪 Development Tools

### Python
```powershell
py             # python
pipi <pkg>     # pip install
pipu <pkg>     # pip upgrade
venva          # Activate venv
deactivate     # Deactivate venv
```

### Node.js
```powershell
nr <script>    # npm run
ns             # npm start
ni             # npm install
nid <pkg>      # npm install --save-dev
nig <pkg>      # npm install -g
```

### Rust
```powershell
c              # cargo
cb             # cargo build
cbr            # cargo build --release
cr             # cargo run
ct             # cargo test
```

## 🪟 Windows Utilities

```powershell
# Control Panel
appwiz         # Programs and Features
inetcpl        # Internet Options
ncpa           # Network Connections
sysdm          # System Properties
firewall       # Windows Firewall

# Administrative Tools
devmgmt        # Device Manager
diskmgmt       # Disk Management
tasksched      # Task Scheduler
services       # Services
eventvwr       # Event Viewer

# System Functions
hosts          # Edit hosts file
emptytrash     # Empty Recycle Bin
flushdns       # Clear DNS cache
```

## ⚙️ Configuration

### Select Mode

```powershell
# Set mode in your profile
$env:POWERCONFIG_MODE = "basic"        # Minimal setup
$env:POWERCONFIG_MODE = "advanced"     # Full features (default)
$env:POWERCONFIG_MODE = "ultra-nerd"   # Everything
```

### Local Customizations

Create a local profile for machine-specific settings:

```powershell
# %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.local.ps1
# Your custom settings here
```

## 🔧 Functions

### File Operations
```powershell
mkcd <dir>          # Create directory and cd into it
touch <file>        # Create file or update timestamp
backup <file>       # Backup with timestamp
extract <archive>   # Extract any archive
compress <out> <files>  # Create archive
```

### Search
```powershell
ftext <pattern>     # Search text in files
ff <name>           # Find files
fdir <name>         # Find directories
```

### Network
```powershell
myip                # Show internal/external IPs
serve [port]        # Start HTTP server
ports               # List listening ports
weather [location]  # Show weather
```

### Development
```powershell
lazyg "msg"         # Git add, commit, push
mkvenv [name]       # Create Python venv
docker-clean        # Clean Docker resources
passgen [len]       # Generate password
```

## 🎨 Modern Tools Integration

### FZF (Fuzzy Finder)
```powershell
fcd                 # Fuzzy cd
fe                  # Fuzzy edit
fbr                 # Fuzzy git branch
fkill               # Fuzzy process kill
fhist               # Fuzzy history
```

### Zoxide
```powershell
z <dir>             # Smart cd
zi                  # Interactive cd
```

## 📦 Recommended Scoop Buckets

```powershell
# Install essential buckets
scoop bucket add extras
scoop bucket add versions
scoop bucket add nirsoft
scoop bucket add sysinternals

# Or use the helper function
Install-ScoopBuckets
```

## 🔧 Troubleshooting

### PowerShell execution policy
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Profile not loading
```powershell
Test-Path $PROFILE              # Check if profile exists
New-Item -Path $PROFILE -Force  # Create if missing
. $PROFILE                       # Reload
```

### Starship not showing
```powershell
# Install Starship
scoop install starship
# or
choco install starship
```

## 🤝 Contributing

Contributions are welcome! Please submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Scoop](https://scoop.sh/) - Windows package manager
- [Chocolatey](https://chocolatey.org/) - Windows package manager
- [Winget](https://docs.microsoft.com/en-us/windows/package-manager/) - Microsoft package manager
- [Starship](https://starship.rs/) - Cross-shell prompt
- [FZF](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- All the amazing open-source projects

---

**Made with ❤️ for Windows Power Users**

⭐ Star this repo if it helps you!
