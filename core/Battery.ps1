function global:Get-BatteryStatus {
    try {
        $bat = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
        if (-not $bat) { return $null }
        $pct = $bat.EstimatedChargeRemaining
        $state = if ($bat.BatteryStatus -eq 2) { "Charging" } elseif ($bat.BatteryStatus -eq 1) { "Discharging" } else { "Unknown" }
        [PSCustomObject]@{
            Percent   = $pct
            State     = $state
            Remaining = if ($bat.EstimatedRunTime -gt 0) { "$($bat.EstimatedRunTime) min" } else { "N/A" }
        }
    } catch { $null }
}

function global:battery {
    $info = Get-BatteryStatus
    if (-not $info) { Write-Host "No battery detected" -ForegroundColor Yellow; return }
    $pct = $info.Percent
    $icon = if ($info.State -eq "Charging") { "[CHG]" } elseif ($pct -le 10) { "[CRIT]" } elseif ($pct -le 30) { "[LOW]" } elseif ($pct -le 70) { "[OK]" } else { "[FULL]" }
    Write-Host "$icon $pct% ($($info.State))" -ForegroundColor Cyan
}

function global:bat_percent {
    $info = Get-BatteryStatus
    if ($info) { $info.Percent } else { $null }
}

function global:is_charging {
    $info = Get-BatteryStatus
    if ($info) { $info.State -eq "Charging" } else { $false }
}
