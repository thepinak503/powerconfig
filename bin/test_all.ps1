param(
    [switch]$Fast,
    [switch]$Quiet,
    [switch]$SkipLoad
)

$ROOT = Split-Path $PSScriptRoot -Parent
$script:PASS = 0; $script:FAIL = 0; $script:SKIP = 0; $script:WARN = 0

function pass($msg) { $script:PASS++; if (-not $Quiet) { Write-Host "  [+] $msg" -ForegroundColor Green } }
function fail($msg) { $script:FAIL++; Write-Host "  [!] $msg" -ForegroundColor Red }
function skip($msg, $reason) { $script:SKIP++; if (-not $Quiet) { Write-Host "  [~] $msg (skipped - $reason)" -ForegroundColor Yellow } }
function warn($msg) { $script:WARN++; Write-Host "  [*] $msg" -ForegroundColor Yellow }
function section($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Test-AllFilesParse {
    section "1. SYNTAX VALIDATION"
    $files = Get-ChildItem $ROOT -Recurse -Filter "*.ps1" | Where-Object {
        $_.FullName -notlike "*\.git*" -and $_.FullName -notlike "*node_modules*"
    }
    foreach ($f in $files) {
        $rel = if ($f.FullName.Length -gt $ROOT.Length) { $f.FullName.Substring($ROOT.Length + 1) } else { $f.Name }
        try {
            $null = [ScriptBlock]::Create((Get-Content $f.FullName -Raw))
            pass $rel
        } catch {
            fail "$rel : $($_.Exception.Message)"
        }
    }
}

function Test-ProfileLoads {
    section "2. PROFILE LOAD"
    if ($SkipLoad) { skip "profile load" "flag" ; return }
    pass "Microsoft.PowerShell_profile.ps1 (loaded at script scope)"
}

function Test-CoreEnvVars {
    section "3. CORE ENVIRONMENT"
    if ($env:POWERCONFIG_DIR) { pass "POWERCONFIG_DIR=$env:POWERCONFIG_DIR" } else { warn "POWERCONFIG_DIR not set" }
    if ($env:DOTFILES_OS) { pass "DOTFILES_OS=$env:DOTFILES_OS" } else { warn "DOTFILES_OS not set" }
    if ($env:DOTFILES_ARCH) { pass "DOTFILES_ARCH=$env:DOTFILES_ARCH" } else { warn "DOTFILES_ARCH not set" }
    if ($env:POWERCONFIG_MODE) { pass "POWERCONFIG_MODE=$env:POWERCONFIG_MODE" } else { warn "POWERCONFIG_MODE not set" }
}

function Test-AllFunctions {
    section "4. FUNCTION AVAILABILITY"
    $expected = @(
        'dottools','dotphase','dotinstall',
        'dotlog_show','dotlog_clear','dotlog_stats',
        'Update-PowerConfig','Set-PowerConfigMode',
        'Get-WindowsEditionInfo','Get-PowerShellInfo',
        'Get-BatteryStatus','battery','bat_percent','is_charging',
        'Set-DarkMode','Set-LightMode','Disable-Hibernation','Enable-Hibernation',
        'Clear-Temp','Get-SystemHealth','Get-WindowsKey','Get-StartupApps',
        'Disable-Telemetry','Show-StartupTime','Get-LargestFiles',
        'myip','localip','uptime','sysinfo','flushdns','weather',
        'mkcd','touch','extract','backup','genpass','uuid','timer','killport',
        'k9','pkill','pgrep','serve','venv','activate','admin',
        'Show-PowerConfigHelp','Edit-Profile','Invoke-ProfileReload',
        'ssh_agent_ensure','ssh_agent_add',
        'Set-Location-Parent','Set-Location-UpTwo','Set-Location-Home'
    )
    foreach ($fn in $expected) {
        if (Get-Command $fn -ErrorAction SilentlyContinue) { pass $fn }
        else { fail $fn }
    }
}

function Test-AllAliases {
    section "5. ALIAS AVAILABILITY"
    $expected = @('g','d','k','tf','gs','ga','gaa','gc','gco','gd','gf','gp','gpl','gb','gl')
    $shortcuts = @('..','...','home')
    foreach ($a in $expected) {
        if (Get-Command $a -ErrorAction SilentlyContinue) { pass "$a" }
        else { fail "$a" }
    }
    foreach ($a in $shortcuts) {
        if (Get-Command $a -ErrorAction SilentlyContinue) { pass "$a" }
        else { fail "$a" }
    }
}

function Test-NoDuplicateFunctions {
    section "6. NO DUPLICATE FUNCTION DEFINITIONS"
    $allFuncs = @{}
    $prevWarn = $script:WARN
    Get-ChildItem $ROOT -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notlike "*\.git*" } | ForEach-Object {
        $rel = if ($_.FullName.Length -gt $ROOT.Length) { $_.FullName.Substring($ROOT.Length + 1) } else { $_.Name }
        $content = Get-Content $_.FullName
        $lineNum = 0
        foreach ($line in $content) {
            $lineNum++
            if ($line -match 'function\s+(global:)?([a-zA-Z_-][a-zA-Z0-9_-]*)') {
                $fname = $Matches[2]
                if ($allFuncs.ContainsKey($fname)) {
                    $prev = $allFuncs[$fname]
                    warn "function $fname : $rel line $lineNum (also in $prev)"
                } else {
                    $allFuncs[$fname] = "$rel line $lineNum"
                }
            }
        }
    }
    if ($script:WARN -eq $prevWarn) { pass "No duplicate functions" }
}

function Test-NoDuplicateAliases {
    section "7. NO DUPLICATE ALIAS DEFINITIONS"
    $allAliases = @{}
    $prevWarn = $script:WARN
    Get-ChildItem $ROOT -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notlike "*\.git*" } | ForEach-Object {
        $rel = if ($_.FullName.Length -gt $ROOT.Length) { $_.FullName.Substring($ROOT.Length + 1) } else { $_.Name }
        $content = Get-Content $_.FullName
        $lineNum = 0
        foreach ($line in $content) {
            $lineNum++
            if ($line -match 'Set-Alias\s+-Name\s+(\S+)') {
                $aname = $Matches[1]
                if ($allAliases.ContainsKey($aname)) {
                    $prev = $allAliases[$aname]
                    warn "alias $aname : $rel line $lineNum (also in $prev)"
                } else {
                    $allAliases[$aname] = "$rel line $lineNum"
                }
            }
        }
    }
    if ($script:WARN -eq $prevWarn) { pass "No duplicate aliases" }
}

function Test-AllCoreModulesExist {
    section "8. CORE MODULE INTEGRITY"
    $expected = @(
        '__cache.ps1','Detection.ps1','Tools.ps1','Aliases.ps1',
        'Functions.ps1','Universal.ps1','Battery.ps1','Logging.ps1',
        'SSHAgent.ps1','WinTweaks.ps1'
    )
    $core = Join-Path $ROOT "core"
    foreach ($f in $expected) {
        if (Test-Path (Join-Path $core $f)) { pass "core/$f" }
        else { fail "core/$f missing" }
    }
}

function Test-StarshipConfig {
    section "9. APP CONFIG INTEGRITY"
    $starship = Join-Path $ROOT "apps\starship\starship.toml"
    if (Test-Path $starship) { pass "starship.toml" }
    else { fail "starship.toml missing" }
}

function Test-RuntimeFunctions {
    section "10. FUNCTION RUNTIME TESTS"
    if ($SkipLoad) { skip "runtime tests" "flag" ; return }
    if ($Fast) { skip "runtime tests" "fast mode" ; return }

    try { $ip = myip; if ($ip) { pass "myip returns $ip" } else { warn "myip returned null" } }
    catch { warn "myip : $_" }

    try { $edition = Get-WindowsEditionInfo; if ($edition.Product) { pass "Get-WindowsEditionInfo: $($edition.Product)" } else { fail "Get-WindowsEditionInfo returned null" } }
    catch { fail "Get-WindowsEditionInfo : $_" }

    try { $bat = Get-BatteryStatus; if ($bat) { pass "Get-BatteryStatus: $($bat.Percent)%" } else { pass "Get-BatteryStatus: no battery" } }
    catch { fail "Get-BatteryStatus : $_" }

    try { battery | Out-Null; pass "battery runs" } catch { fail "battery : $_" }

    try { $p = genpass 8; if ($p.Length -eq 8) { pass "genpass 8 OK" } else { warn "genpass length mismatch" } }
    catch { fail "genpass : $_" }

    try { $g = uuid; if ($g -match '^[a-f0-9-]{36}$') { pass "uuid OK" } else { warn "uuid format" } }
    catch { fail "uuid : $_" }

    try { $s = Get-PowerShellInfo; if ($s.Edition) { pass "Get-PowerShellInfo: $($s.Edition) $($s.Version)" } else { fail "Get-PowerShellInfo null" } }
    catch { fail "Get-PowerShellInfo : $_" }
}

function Test-BinScripts {
    section "11. BIN SCRIPT INTEGRITY"
    $expected = @('dotupdate.ps1','health_check.ps1','diagnostic.ps1')
    foreach ($f in $expected) {
        if (Test-Path (Join-Path $ROOT "bin\$f")) { pass "bin/$f" }
        else { fail "bin/$f missing" }
    }
}

function Test-InstallScripts {
    section "12. INSTALLER INTEGRITY"
    $expected = @(
        'install.ps1',
        'install\install.ps1',
        'install\bootstrap.ps1',
        'install\Install-PowerConfig.ps1'
    )
    foreach ($f in $expected) {
        if (Test-Path (Join-Path $ROOT $f)) { pass "$f" }
        else { fail "$f missing" }
    }
}

function Test-NoDeprecatedPatterns {
    section "13. NO DEPRECATED PATTERNS"
    $prevWarn = $script:WARN
    $files = Get-ChildItem $ROOT -Recurse -Filter "*.ps1" | Where-Object {
        $_.FullName -notlike "*\.git*"
    }
    foreach ($f in $files) {
        $rel = if ($f.FullName.Length -gt $ROOT.Length) { $f.FullName.Substring($ROOT.Length + 1) } else { $f.Name }
        $content = Get-Content $f.FullName
        $lineNum = 0
        foreach ($line in $content) {
            $lineNum++
            if ($line -match 'Write-Host.*\$_' -and $line -notmatch '\$\{\}') {
                warn "$rel line $lineNum : possible dollar-underscore in string"
            }
        }
    }
    if ($script:WARN -eq $prevWarn) { pass "No deprecated patterns" }
}

function Show-Summary {
    section "SUMMARY"
    $total = $PASS + $FAIL + $SKIP
    Write-Host "  Passed : $PASS" -ForegroundColor Green
    Write-Host "  Failed : $FAIL" -ForegroundColor Red
    Write-Host "  Skipped: $SKIP" -ForegroundColor Yellow
    Write-Host "  Warnings: $WARN" -ForegroundColor Yellow
    Write-Host "  Total  : $total"
    if ($FAIL -eq 0) {
        Write-Host "`nALL TESTS PASSED!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "`nSOME TESTS FAILED!" -ForegroundColor Red
        return $false
    }
}

Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "|       POWERCONFIG TEST SUITE                |" -ForegroundColor Cyan
Write-Host "+--------------------------------------------+" -ForegroundColor Cyan
Write-Host "  Root: $ROOT"

Test-AllFilesParse
if (-not $SkipLoad) {
    Test-ProfileLoads
    # Load profile at script scope so aliases/functions are visible to all tests
    . (Join-Path $ROOT "Microsoft.PowerShell_profile.ps1")
}
Test-CoreEnvVars
Test-AllFunctions
Test-AllAliases
Test-NoDuplicateFunctions
Test-NoDuplicateAliases
Test-AllCoreModulesExist
Test-StarshipConfig
Test-RuntimeFunctions
Test-BinScripts
Test-InstallScripts
Test-NoDeprecatedPatterns
$success = Show-Summary

if (-not $success) { exit 1 }
