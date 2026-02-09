# PowerConfig Functions
# Comprehensive PowerShell utility functions

#region File & Directory Operations
function mkcd {
    <#
    .SYNOPSIS
        Create a directory and change into it
    .PARAMETER Path
        Directory path to create
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function touch {
    <#
    .SYNOPSIS
        Create a new file or update timestamp of existing file
    .PARAMETER Path
        File path
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }
}

function backup {
    <#
    .SYNOPSIS
        Backup a file with timestamp
    .PARAMETER Path
        File to backup
    #>
    param([Parameter(Mandatory)][string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "$Path.bak.$timestamp"
    
    Copy-Item -Path $Path -Destination $backupPath
    Write-Host "Backed up: $Path → $backupPath" -ForegroundColor Green
}

function extract {
    <#
    .SYNOPSIS
        Extract any archive format
    .PARAMETER Path
        Archive file to extract
    .PARAMETER Destination
        Destination directory (optional)
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Destination = "."
    )
    
    if (-not (Test-Path $Path)) {
        Write-Error "Archive not found: $Path"
        return
    }
    
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($ext) {
        '.zip' { Expand-Archive -Path $Path -DestinationPath $Destination }
        '.tar' { tar -xf $Path -C $Destination }
        '.gz' { tar -xzf $Path -C $Destination }
        '.tgz' { tar -xzf $Path -C $Destination }
        '.bz2' { tar -xjf $Path -C $Destination }
        '.xz' { tar -xJf $Path -C $Destination }
        '.7z' { 
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $Path -o$Destination
            } else {
                Write-Error "7z not found. Install with: scoop install 7zip"
            }
        }
        '.rar' {
            if (Get-Command unrar -ErrorAction SilentlyContinue) {
                unrar x $Path $Destination
            } else {
                Write-Error "unrar not found"
            }
        }
        default { Write-Error "Unknown archive format: $ext" }
    }
}

function compress {
    <#
    .SYNOPSIS
        Create an archive from files
    .PARAMETER Path
        Archive file path
    .PARAMETER Items
        Items to include
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory, ValueFromRemainingArguments)][string[]]$Items
    )
    
    $ext = [System.IO.Path]::GetExtension($Path).ToLower()
    
    switch ($ext) {
        '.zip' { Compress-Archive -Path $Items -DestinationPath $Path }
        '.tar' { tar -cf $Path $Items }
        '.gz' { tar -czf $Path $Items }
        '.tgz' { tar -czf $Path $Items }
        '.bz2' { tar -cjf $Path $Items }
        default { Write-Error "Unknown archive format: $ext" }
    }
}

function size {
    <#
    .SYNOPSIS
        Get size of files or directories
    .PARAMETER Path
        Path to check
    #>
    param([Parameter(Mandatory)][string]$Path = ".")
    
    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }
    
    $item = Get-Item $Path
    if ($item.PSIsContainer) {
        $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
    } else {
        $size = $item.Length
    }
    
    switch ($size) {
        { $_ -gt 1GB } { "{0:N2} GB" -f ($_ / 1GB); break }
        { $_ -gt 1MB } { "{0:N2} MB" -f ($_ / 1MB); break }
        { $_ -gt 1KB } { "{0:N2} KB" -f ($_ / 1KB); break }
        default { "{0} B" -f $_ }
    }
}

function emptytrash {
    <#
    .SYNOPSIS
        Empty the Recycle Bin
    #>
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -lt 6)) {
        Clear-RecycleBin -Force
        Write-Host "Recycle Bin emptied" -ForegroundColor Green
    } else {
        Write-Host "Not supported on this platform" -ForegroundColor Yellow
    }
}
#endregion

#region Search & Find
function ftext {
    <#
    .SYNOPSIS
        Search for text in files
    .PARAMETER Pattern
        Search pattern
    .PARAMETER Path
        Search path (default: current directory)
    #>
    param(
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Path = "."
    )
    
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg -i --color=always $Pattern $Path
    } else {
        Get-ChildItem $Path -Recurse -File | 
            Select-String -Pattern $Pattern | 
            Format-Table -Property Filename, LineNumber, Line -AutoSize
    }
}

function ff {
    <#
    .SYNOPSIS
        Find files by name
    .PARAMETER Name
        File name pattern
    .PARAMETER Path
        Search path
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Path = "."
    )
    
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd $Name $Path
    } else {
        Get-ChildItem $Path -Recurse -Filter "*$Name*" -File
    }
}

function fdir {
    <#
    .SYNOPSIS
        Find directories by name
    .PARAMETER Name
        Directory name pattern
    .PARAMETER Path
        Search path
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Path = "."
    )
    
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd -t d $Name $Path
    } else {
        Get-ChildItem $Path -Recurse -Filter "*$Name*" -Directory
    }
}
#endregion

#region Network
function myip {
    <#
    .SYNOPSIS
        Display internal and external IP addresses
    #>
    Write-Host "Internal IPs:" -ForegroundColor Cyan
    Get-NetIPAddress -AddressFamily IPv4 | 
        Where-Object { $_.IPAddress -ne "127.0.0.1" } |
        Select-Object InterfaceAlias, IPAddress |
        Format-Table
    
    Write-Host "External IP:" -ForegroundColor Cyan
    try {
        $external = Invoke-RestMethod -Uri "https://ifconfig.me" -TimeoutSec 5
        Write-Host "  $external" -ForegroundColor Green
    } catch {
        Write-Host "  Could not retrieve" -ForegroundColor Red
    }
}

function serve {
    <#
    .SYNOPSIS
        Start a simple HTTP server
    .PARAMETER Port
        Port number (default: 8080)
    .PARAMETER Path
        Directory to serve (default: current)
    #>
    param(
        [int]$Port = 8080,
        [string]$Path = "."
    )
    
    Write-Host "Serving $Path on http://localhost:$Port" -ForegroundColor Green
    
    if (Get-Command python -ErrorAction SilentlyContinue) {
        python -m http.server $Port --directory $Path
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        python3 -m http.server $Port --directory $Path
    } elseif (Get-Command node -ErrorAction SilentlyContinue) {
        npx serve -p $Port $Path
    } else {
        Write-Error "No suitable server found (python, node)"
    }
}

function ports {
    <#
    .SYNOPSIS
        List listening ports
    #>
    Get-NetTCPConnection -State Listen | 
        Select-Object LocalAddress, LocalPort, @{Name="Process";Expression={(Get-Process -Id $_.OwningProcess).ProcessName}} |
        Format-Table -AutoSize
}

function flushdns {
    <#
    .SYNOPSIS
        Clear DNS cache
    #>
    Clear-DnsClientCache
    Write-Host "DNS cache cleared" -ForegroundColor Green
}

function weather {
    <#
    .SYNOPSIS
        Display weather information
    .PARAMETER Location
        Location (optional)
    #>
    param([string]$Location = "")
    
    try {
        $url = if ($Location) { "wttr.in/$Location?format=v2" } else { "wttr.in/?format=v2" }
        Invoke-RestMethod -Uri $url -TimeoutSec 10
    } catch {
        Write-Error "Could not fetch weather"
    }
}
#endregion

#region Process Management
function psgrep {
    <#
    .SYNOPSIS
        Find process by name
    .PARAMETER Name
        Process name to search
    #>
    param([Parameter(Mandatory)][string]$Name)
    
    Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } | 
        Select-Object Id, ProcessName, CPU, WorkingSet |
        Format-Table -AutoSize
}

function fkill {
    <#
    .SYNOPSIS
        Interactive process killer (requires fzf)
    #>
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Error "fzf not found. Install with: scoop install fzf"
        return
    }
    
    $process = Get-Process | 
        Select-Object Id, ProcessName, CPU | 
        fzf --multi --header="[kill process]" |
        ForEach-Object { ($_ -split "\s+")[0] }
    
    if ($process) {
        Stop-Process -Id $process -Force
        Write-Host "Process killed: $process" -ForegroundColor Green
    }
}

function memhogs {
    <#
    .SYNOPSIS
        Show top processes by memory usage
    .PARAMETER Count
        Number of processes (default: 10)
    #>
    param([int]$Count = 10)
    
    Get-Process | 
        Sort-Object WorkingSet -Descending |
        Select-Object -First $Count |
        Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id |
        Format-Table -AutoSize
}

function cpuhogs {
    <#
    .SYNOPSIS
        Show top processes by CPU usage
    .PARAMETER Count
        Number of processes (default: 10)
    #>
    param([int]$Count = 10)
    
    Get-Process | 
        Sort-Object CPU -Descending |
        Select-Object -First $Count |
        Select-Object ProcessName, CPU, Id |
        Format-Table -AutoSize
}
#endregion

#region Development
function lazyg {
    <#
    .SYNOPSIS
        Git add, commit, and push in one command
    .PARAMETER Message
        Commit message
    #>
    param([Parameter(Mandatory)][string]$Message)
    
    git add .
    git commit -m "$Message"
    git push
}

function mkvenv {
    <#
    .SYNOPSIS
        Create and activate Python virtual environment
    .PARAMETER Name
        Environment name (default: venv)
    #>
    param([string]$Name = "venv")
    
    python -m venv $Name
    .\$Name\Scripts\Activate.ps1
}

function passgen {
    <#
    .SYNOPSIS
        Generate secure password
    .PARAMETER Length
        Password length (default: 16)
    .PARAMETER Count
        Number of passwords (default: 1)
    #>
    param(
        [int]$Length = 16,
        [int]$Count = 1
    )
    
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    
    for ($i = 0; $i -lt $Count; $i++) {
        -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    }
}

function json {
    <#
    .SYNOPSIS
        Format JSON (pretty print)
 .PARAMETER Input
        JSON string or file path
    #>
    param([Parameter(Mandatory, ValueFromPipeline)][string]$Input)
    
    process {
        if (Test-Path $Input) {
            Get-Content $Input | ConvertFrom-Json | ConvertTo-Json -Depth 10
        } else {
            $Input | ConvertFrom-Json | ConvertTo-Json -Depth 10
        }
    }
}

function urlencode {
    <#
    .SYNOPSIS
        URL encode a string
    .PARAMETER String
        String to encode
    #>
    param([Parameter(Mandatory)][string]$String)
    
    [System.Web.HttpUtility]::UrlEncode($String)
}

function urldecode {
    <#
    .SYNOPSIS
        URL decode a string
    .PARAMETER String
        String to decode
    #>
    param([Parameter(Mandatory)][string]$String)
    
    [System.Web.HttpUtility]::UrlDecode($String)
}

function docker-clean {
    <#
    .SYNOPSIS
        Clean up Docker resources
    #>
    Write-Host "Removing stopped containers..." -ForegroundColor Yellow
    docker container prune -f
    
    Write-Host "Removing unused images..." -ForegroundColor Yellow
    docker image prune -f
    
    Write-Host "Removing unused volumes..." -ForegroundColor Yellow
    docker volume prune -f
    
    Write-Host "Removing unused networks..." -ForegroundColor Yellow
    docker network prune -f
    
    Write-Host "Docker cleanup complete!" -ForegroundColor Green
}
#endregion

#region System Utilities
function sysinfo {
    <#
    .SYNOPSIS
        Display system information
    #>
    $info = Get-ComputerInfo
    
    [PSCustomObject]@{
        "OS" = $info.WindowsProductName
        "Version" = $info.WindowsVersion
        "Architecture" = $info.OsArchitecture
        "Total RAM" = "{0:N2} GB" -f ($info.TotalPhysicalMemory / 1GB)
        "Processors" = $info.CsProcessors.Count
        "Boot Time" = $info.OsLastBootUpTime
    } | Format-List
}

function diskusage {
    <#
    .SYNOPSIS
        Display disk usage
    #>
    Get-Volume | 
        Where-Object { $_.DriveLetter } |
        Select-Object DriveLetter, 
            @{Name="Size(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name="Used(GB)";Expression={[math]::Round(($_.Size - $_.SizeRemaining) / 1GB, 2)}},
            @{Name="Free(GB)";Expression={[math]::Round($_.SizeRemaining / 1GB, 2)}},
            @{Name="Usage";Expression={[math]::Round((($_.Size - $_.SizeRemaining) / $_.Size) * 100, 1)}} |
        Format-Table -AutoSize
}

function uptime {
    <#
    .SYNOPSIS
        Show system uptime
    #>
    $bootTime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "System uptime: $($bootTime.Days) days, $($bootTime.Hours) hours, $($bootTime.Minutes) minutes"
}

function emptybin {
    <#
    .SYNOPSIS
        Empty Recycle Bin
    #>
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin emptied" -ForegroundColor Green
}
#endregion

#region Quick Access
function docs { Set-Location $env:USERPROFILE\Documents }
function desktop { Set-Location $env:USERPROFILE\Desktop }
function downloads { Set-Location $env:USERPROFILE\Downloads }
function home { Set-Location $env:USERPROFILE }
function tmp { Set-Location $env:TEMP }
#endregion
