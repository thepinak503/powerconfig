# PowerConfig Theme - Tokyo Night Aesthetics

if (Get-Command starship -EA SilentlyContinue) {
    $STARSHIP_CONFIG = Join-Path $env:POWERCONFIG_DIR "apps/starship/starship.toml"
    if (Test-Path $STARSHIP_CONFIG) {
        $env:STARSHIP_CONFIG = $STARSHIP_CONFIG
        Invoke-Expression (&starship init powershell)
    }
} else {
    function prompt { "PS $($ExecutionContext.SessionState.Path.CurrentLocation)> " }
}

# Update Windows Terminal Title
$Host.UI.RawUI.WindowTitle = "PowerConfig | $($PSVersionTable.PSVersion)"
