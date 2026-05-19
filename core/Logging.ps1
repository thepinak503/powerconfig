$env:POWERCONFIG_LOG_FILE = "$env:POWERCONFIG_STATE_DIR\powerconfig.log"

function global:Write-PowerConfigLog {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Message" | Out-File $env:POWERCONFIG_LOG_FILE -Append -Encoding UTF8
}

function global:dotlog_show {
    param([int]$n = 50)
    if (Test-Path $env:POWERCONFIG_LOG_FILE) {
        Get-Content $env:POWERCONFIG_LOG_FILE -Tail $n
    } else {
        Write-Host "No log file." -ForegroundColor Yellow
    }
}

function global:dotlog_clear {
    if (Test-Path $env:POWERCONFIG_LOG_FILE) {
        Clear-Content $env:POWERCONFIG_LOG_FILE
        Write-Host "Log cleared." -ForegroundColor Green
    }
}

function global:dotlog_stats {
    if (Test-Path $env:POWERCONFIG_LOG_FILE) {
        $lines = (Get-Content $env:POWERCONFIG_LOG_FILE).Count
        Write-Host "Log lines: $lines" -ForegroundColor Cyan
    } else {
        Write-Host "No log file." -ForegroundColor Yellow
    }
}
