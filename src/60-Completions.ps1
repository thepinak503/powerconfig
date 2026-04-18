# PowerConfig Completions - PSReadLine & Completers

# PSReadLine Options (PowerShell 7+ only)
$PSReadLineModule = Get-Module PSReadLine -ListAvailable
if ($PSReadLineModule -and $PSVersionTable.PSEdition -eq "Core") {
    try {
        Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
        Set-PSReadLineOption -Colors @{
            Command = "#7aa2f7"
            Parameter = "#bb9af7"
            Operator = "#89ddff"
            Variable = "#c0caf5"
            String = "#9ece6a"
            Comment = "#565f89"
        } -ErrorAction SilentlyContinue

        # Key Handlers
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
    } catch { }
}

# Native Argument Completers
Register-ArgumentCompleter -Native -CommandName git, npm, pnpm, yarn, docker, kubectl -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    # Placeholder for logic
}
