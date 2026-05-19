param([switch]$Force)
$root = Split-Path $PSScriptRoot -Parent
Write-Host "Updating PowerConfig..." -ForegroundColor Cyan
if (Test-Path (Join-Path $root ".git")) {
    $stash = if (-not $Force) { "git -C '$root' stash" } else { "" }
    git -C $root fetch --all --prune
    git -C $root pull --rebase --autostash
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PowerConfig updated!" -ForegroundColor Green
        Write-Host "Run 'reload-profile' to apply changes" -ForegroundColor Cyan
    } else {
        Write-Host "Update failed. Try with -Force" -ForegroundColor Red
    }
} else {
    Write-Host "Not a git repository. Clone with:" -ForegroundColor Yellow
    Write-Host "git clone https://github.com/thepinak503/powerconfig.git" -ForegroundColor Cyan
}
