# PowerConfig Completions - PSReadLine & Completers

# PSReadLine Options (Inspired by CTT)
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -Colors @{
        Command = "#7aa2f7"
        Parameter = "#bb9af7"
        Operator = "#89ddff"
        Variable = "#c0caf5"
        String = "#9ece6a"
        Comment = "#565f89"
    }

    # Key Handlers
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Native Argument Completers
Register-ArgumentCompleter -Native -CommandName git, npm, pnpm, yarn, docker, kubectl -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    # Placeholder for logic
}
