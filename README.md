# ⚡ PowerConfig
The Ultimate PowerShell Configuration

PowerConfig is a comprehensive, modular PowerShell configuration designed for power users on Windows, macOS, and Linux. It features extensive aliases, functions, and integrations with modern CLI tools, along with full support for package managers on all platforms.

GitHub stars (https://github.com/thepinak503/powerconfig/stargazers)
License (LICENSE)
✨ Features
🌍 Cross-Platform Design
- Windows: Native commands, Windows Terminal, Control Panel, administrative tools
- macOS: System preferences, Finder, terminal, Homebrew support
- Linux: APT, DNF, Pacman, Snap, systemd, and more
- Universal: Same configuration works everywhere with platform detection
📦 Package Manager Support
- Windows: Scoop, Chocolatey, Winget
- macOS: Homebrew
- Linux: APT, DNF, Pacman, Snap
- Universal aliases: pinstall, psearch, pupdate work with any manager
🛠️ Development Ready
- Python: pip, poetry, conda support (cross-platform)
- Node.js: npm, yarn, pnpm support (cross-platform)
- Rust: Cargo integration (cross-platform)
- Go: Full Go toolchain support (cross-platform)
- Docker: Complete Docker/Docker Compose aliases (cross-platform)
- Kubernetes: kubectl and Helm shortcuts (cross-platform)
- Terraform: Infrastructure as code (cross-platform)
- AWS/Azure/GCP: Cloud provider integration (cross-platform)
🔧 Modern Tools
- Starship: Cross-shell prompt (cross-platform)
- FZF: Fuzzy finder with PowerShell keybindings (cross-platform)
- Zoxide: Smart directory jumping (cross-platform)
- Eza: Modern ls replacement (cross-platform)
- Bat: Syntax-highlighting cat (cross-platform)
- Ripgrep: Lightning-fast grep (cross-platform)
- Delta: Beautiful git diffs (cross-platform)
- Dust: Modern du replacement (cross-platform)
🎯 Three Configuration Modes
- Basic: Essential aliases, minimal setup
- Advanced: Full aliases, modern tools (default)
- Ultra-Nerd: Everything + maximum features
🚀 Installation
Quick Install (One Command)
# Using PowerShell 5.1 or PowerShell Core
irm https://raw.githubusercontent.com/thepinak503/powerconfig/main/install.ps1 | iex
Manual Installation
# Clone the repository
git clone https://github.com/thepinak503/powerconfig.git $env:POWERCONFIG_DIR
# Run the installer
& $env:POWERCONFIG_DIR/install.ps1
Prerequisites
- PowerShell 5.1 or PowerShell Core 7.0+
- Git
- Windows 10/11 (also works on Windows Server)
- macOS 10.15+ (also works on macOS Server)
- Linux (Ubuntu, Debian, Fedora, Arch, etc.)
📁 Structure
$env:POWERCONFIG_DIR\
├── Microsoft.PowerShell_profile.ps1  # Main entry point
├── install.ps1                       # One-command installer
├── README.md
├── LICENSE
├── Modules/                          # PowerShell modules
│   ├── Aliases.ps1                  # Core aliases (cross-platform)
│   ├── Functions.ps1                # Utility functions (cross-platform)
│   ├── PackageManagers.ps1          # Scoop/Choco/Winget (Windows only)
│   ├── Development.ps1              # Dev tools support (cross-platform)
│   ├── ModernTools.ps1              # Modern CLI tools (cross-platform)
│   └── Windows.ps1                  # Windows-specific utilities
└── Themes/                          # Custom themes (optional)
📋 Package Manager Aliases
Universal Package Management
pinstall <package>   # Install using any available manager
psearch <query>      # Search across all managers
pupdate              # Update all packages
Windows Package Managers
# Scoop
s              # scoop
si <package>   # scoop install
sun <package>  # scoop uninstall
su             # scoop update
sup            # scoop update *
ss <query>     # scoop search
sls            # scoop list
sc             # scoop cleanup *
# Chocolatey
ch             # choco
chi <package>  # choco install
chun <package> # choco uninstall
chup <package> # choco upgrade
cha            # choco upgrade all
chs <query>    # choco search
chls           # choco list --local-only
# Winget
w              # winget
wi <package>   # winget install
wun <package>  # winget uninstall
wup <package>  # winget upgrade
wua            # winget upgrade --all
ws <query>     # winget search
wls            # winget list
macOS Package Manager
# Homebrew
brew           # brew
bi <formula>   # brew install
bun <formula>  # brew uninstall
bup <formula>  # brew upgrade
bau            # brew upgrade --all
bs <query>     # brew search
bls            # brew list
Linux Package Managers
# APT (Ubuntu/Debian)
apti <pkg>     # apt install
apts <pkg>     # apt search
aptu           # apt update && apt upgrade
# DNF (Fedora)
dnfi <pkg>     # dnf install
dnfs <pkg>     # dnf search
dnfu           # dnf update
# Pacman (Arch)
pacmani <pkg>  # pacman -S
pacmanu        # pacman -Syu
🐙 Git Aliases
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
🐳 Docker Aliases
d              # docker
dc             # docker-compose (or docker compose)
dps            # docker ps (formatted)
dpa            # docker ps -a
di             # docker images
dex <name>     # docker exec -it
dr <image>     # docker run -it --rm
dprune         # Clean up Docker
☸️ Kubernetes Aliases
k              # kubectl
kg             # kubectl get
kd             # kubectl describe
kl             # kubectl logs
kgp            # kubectl get pods
kgd            # kubectl get deployment
h              # helm
hin            # helm install
hup            # helm upgrade
🧪 Development Tools
Python
py             # python (auto-detects python3)
pipi <pkg>     # pip install
pipu <pkg>     # pip upgrade
venv           # Create venv
venva          # Activate venv (cross-platform)
deactivate     # Deactivate venv
Node.js
nr <script>    # npm run
ns             # npm start
ni             # npm install
nid <pkg>      # npm install --save-dev
nig <pkg>      # npm install -g
Rust
c              # cargo
cb             # cargo build
cbr            # cargo build --release
cr             # cargo run
ct             # cargo test
🌏 Windows Utilities
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
emptytrash     # Empty Recycle Bin/Trash
flushdns       # Clear DNS cache
🔧 Configuration
Select Mode
# Set mode in your profile
$env:POWERCONFIG_MODE = "basic"        # Minimal setup
$env:POWERCONFIG_MODE = "advanced"     # Full features (default)
$env:POWERCONFIG_MODE = "ultra-nerd"   # Everything
Local Customizations
Create a local profile for machine-specific settings:
# $env:POWERCONFIG_DIR/Microsoft.PowerShell_profile.local.ps1
# Your custom settings here
🔧 Functions
File Operations
mkcd <dir>          # Create directory and cd into it
touch <file>        # Create file or update timestamp
backup <file>       # Backup with timestamp
extract <archive>   # Extract any archive
compress <out> <files>  # Create archive
Search
ftext <pattern>     # Search text in files
ff <name>           # Find files
fdir <name>         # Find directories
Network
myip                # Show internal/external IPs
serve [port]        # Start HTTP server
ports               # List listening ports
weather [location]  # Show weather
Development
lazyg "msg"         # Git add, commit, push
mkvenv [name]       # Create Python venv
docker-clean        # Clean Docker resources
passgen [len]       # Generate password
🎨 Modern Tools Integration
FZF (Fuzzy Finder)
fcd                 # Fuzzy cd
fe                  # Fuzzy edit
fbr                 # Fuzzy git branch
fkill               # Fuzzy process kill
fhist               # Fuzzy history
Zoxide
z <dir>             # Smart cd
zi                  # Interactive cd
🔍 Troubleshooting
PowerShell execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Profile not loading
Test-Path $PROFILE              # Check if profile exists
New-Item -Path $PROFILE -Force  # Create if missing
. $PROFILE                       # Reload
Starship not showing
# Install Starship
pinstall starship
# or
pinstall starship
🤝 Contributing
Contributions are welcome! Please submit a Pull Request.
1. Fork the repository
2. Create your feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request
📝 License
MIT License - see LICENSE (LICENSE) file for details.
🙏 Acknowledgments
- Scoop (https://scoop.sh/) - Windows package manager
- Chocolatey (https://chocolatey.org/) - Windows package manager
- Winget (https://docs.microsoft.com/en-us/windows/package-manager/) - Microsoft package manager
- Starship (https://starship.rs/) - Cross-shell prompt
- FZF (https://github.com/junegunn/fzf) - Command-line fuzzy finder
- All the amazing open-source projects
---
Made with ❤️ for Windows, macOS, and Linux Power Users
⭐ Star this repo if it helps you!