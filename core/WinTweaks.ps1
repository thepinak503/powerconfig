function global:Set-DarkMode {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    Write-Host "Dark mode enabled (may need logoff)" -ForegroundColor Green
}

function global:Set-LightMode {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 1
    Write-Host "Light mode enabled (may need logoff)" -ForegroundColor Green
}

function global:Disable-Hibernation {
    Start-Process powercfg -ArgumentList "/hibernate off" -Verb RunAs -Wait
    Write-Host "Hibernation disabled" -ForegroundColor Green
}

function global:Enable-Hibernation {
    Start-Process powercfg -ArgumentList "/hibernate on" -Verb RunAs -Wait
    Write-Host "Hibernation enabled" -ForegroundColor Green
}

function global:Clear-Temp {
    $paths = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
    )
    foreach ($p in $paths) {
        Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Temp files cleared" -ForegroundColor Green
}

function global:Get-WindowsKey {
    $map = "BCDFGHJKMPQRTVWXY2346789"
    $value = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DigitalProductId[0x34..0x42]
    $key = ""
    for ($i = 24; $i -ge 0; $i--) {
        $r = 0
        for ($j = 14; $j -ge 0; $j--) {
            $r = ($r * 256) -bxor $value[$j]
            $value[$j] = [math]::Floor($r / 24)
            $r = $r % 24
        }
        $key = $map[$r] + $key
        if (($i % 5) -eq 0 -and $i -ne 0) { $key = "-" + $key }
    }
    $key
}

function global:Get-StartupApps {
    Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table -AutoSize
}

function global:Get-SystemHealth {
    Write-Host "=== System Health ===" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "OS: $($os.Caption) - Build $($os.BuildNumber)"
    Write-Host "Uptime: $((Get-Date)-$os.LastBootUpTime | Select-Object @{N='Uptime';E={"{0}d {1}h {2}m" -f $_.Days, $_.Hours, $_.Minutes}}).Uptime"
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,1)}}, @{N='TotalGB';E={[math]::Round($_.Size/1GB,1)}}
    $disk | ForEach-Object { Write-Host "$($_.DeviceID) $($_.FreeGB)GB / $($_.TotalGB)GB free" }
    $mem = Get-CimInstance Win32_OperatingSystem
    Write-Host "RAM: $([math]::Round(($mem.TotalVisibleMemorySize-$mem.FreePhysicalMemory)/1MB,1))GB / $([math]::Round($mem.TotalVisibleMemorySize/1MB,1))GB used"
}

function global:Disable-Telemetry {
    $paths = @(
        @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name="AllowTelemetry"; Value=0},
        @{Path="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name="AllowTelemetry"; Value=0},
        @{Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; Name="AllowTelemetry"; Value=0}
    )
    foreach ($p in $paths) {
        if (-not (Test-Path $p.Path)) { New-Item -Path $p.Path -Force | Out-Null }
        Set-ItemProperty -Path $p.Path -Name $p.Name -Value $p.Value -Type DWord -Force
    }
    Write-Host "Telemetry disabled (admin req)" -ForegroundColor Green
}

function global:Show-StartupTime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    Write-Host "Boot time: $($boot.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Host "Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)m $($up.Seconds)s" -ForegroundColor Cyan
}

function global:Get-LargestFiles {
    param([int]$n = 10, [string]$Path = "C:\")
    Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $n FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}
}

function global:winutil {
    Write-Host "Launching Chris Titus WinUtil..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri "https://christitus.com/win" | Invoke-Expression
}

function global:pwinutil {
    Write-Host "Launching Chris Titus WinUtil Dev..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri "https://christitus.com/windev" | Invoke-Expression
}
