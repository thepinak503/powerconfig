# PowerConfig Completions - PSReadLine & Completers

# PSReadLine Options (Inspired by CTT) - PowerShell 7+ only
if (Get-Module PSReadLine -ListAvailable) {
    $PSReadLineModule = Get-Module PSReadLine
    if ($PSReadLineModule.Version -ge [version]"2.0.0") {
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
    }
}

# Native Argument Completers
Register-ArgumentCompleter -Native -CommandName git, npm, pnpm, yarn, docker, kubectl -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    # Placeholder for logic
}
