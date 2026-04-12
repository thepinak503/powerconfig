# PowerConfig Aliases - Ultra Consolidated
# World's Most Advanced PowerShell Aliases
# Logic is now consolidated in src/30-Standard.ps1 and 41-Development.ps1

#region NAVIGATION
Set-Alias ".." Go-Up-Parent -Force -ErrorAction SilentlyContinue
Set-Alias home Set-Location-Home -Force -ErrorAction SilentlyContinue
Set-Alias cdd Set-Location-Desktop -Force -ErrorAction SilentlyContinue
Set-Alias docs Set-Location-Documents -Force -ErrorAction SilentlyContinue
Set-Alias dl Set-Location-Downloads -Force -ErrorAction SilentlyContinue
Set-Alias proj Set-Location-Projects -Force -ErrorAction SilentlyContinue
Set-Alias code Set-Location-Code -Force -ErrorAction SilentlyContinue
Set-Alias tmp Set-Location-Temp -Force -ErrorAction SilentlyContinue
#endregion

#region LISTING
Set-Alias l Get-DirectoryListing -Force -ErrorAction SilentlyContinue
Set-Alias la Get-DirectoryListing-All -Force -ErrorAction SilentlyContinue
Set-Alias ll Get-DirectoryListing-Long -Force -ErrorAction SilentlyContinue
Set-Alias lt Get-DirectoryListing-Tree -Force -ErrorAction SilentlyContinue
#endregion

#region FILE OPERATIONS
Set-Alias cp Copy-Item -Force -ErrorAction SilentlyContinue
Set-Alias mv Move-Item -Force -ErrorAction SilentlyContinue
Set-Alias rm Remove-Item -Force -ErrorAction SilentlyContinue
Set-Alias mkdir New-MkDirectory -Force -ErrorAction SilentlyContinue
Set-Alias touch Set-TouchFile -Force -ErrorAction SilentlyContinue
Set-Alias backup Backup-FilePath -Force -ErrorAction SilentlyContinue
Set-Alias mkcd New-MkDirectory -Force -ErrorAction SilentlyContinue
#endregion

#region EDITORS
Set-Alias v Invoke-TextEditor -Force -ErrorAction SilentlyContinue
Set-Alias edit Invoke-TextEditor -Force -ErrorAction SilentlyContinue
Set-Alias e Invoke-TextEditor -Force -ErrorAction SilentlyContinue
#endregion

#region GIT
Set-Alias g git -Force -ErrorAction SilentlyContinue
Set-Alias gs Invoke-GitStatus -Force -ErrorAction SilentlyContinue
Set-Alias ga git-add -Force -ErrorAction SilentlyContinue
Set-Alias gaa git-add-all -Force -ErrorAction SilentlyContinue
Set-Alias gc git-commit -Force -ErrorAction SilentlyContinue
Set-Alias gcm git-commit-message -Force -ErrorAction SilentlyContinue
Set-Alias gco git-checkout -Force -ErrorAction SilentlyContinue
Set-Alias gcb git-checkout-branch -Force -ErrorAction SilentlyContinue
Set-Alias gd git-diff -Force -ErrorAction SilentlyContinue
Set-Alias gf git-fetch -Force -ErrorAction SilentlyContinue
Set-Alias gl git-log -Force -ErrorAction SilentlyContinue
Set-Alias gp git-push -Force -ErrorAction SilentlyContinue
Set-Alias gpl git-pull -Force -ErrorAction SilentlyContinue
#endregion

#region DOCKER
Set-Alias d docker -Force -ErrorAction SilentlyContinue
Set-Alias dc docker-compose -Force -ErrorAction SilentlyContinue
Set-Alias dps docker-ps -Force -ErrorAction SilentlyContinue
#endregion

#region KUBERNETES
Set-Alias k kubectl -Force -ErrorAction SilentlyContinue
Set-Alias kg kubectl-get -Force -ErrorAction SilentlyContinue
Set-Alias kd kubectl-describe -Force -ErrorAction SilentlyContinue
#endregion

#region PYTHON / LANGUAGES
Set-Alias py python -Force -ErrorAction SilentlyContinue
Set-Alias pip Invoke-Pip -Force -ErrorAction SilentlyContinue
Set-Alias venv Invoke-Venv -Force -ErrorAction SilentlyContinue
Set-Alias mkvenv New-PythonVenv -Force -ErrorAction SilentlyContinue
#endregion

#region SYSTEM
Set-Alias cls Clear-Host -Force -ErrorAction SilentlyContinue
Set-Alias clear Clear-Host -Force -ErrorAction SilentlyContinue
Set-Alias h Get-History -Force -ErrorAction SilentlyContinue
Set-Alias hc Clear-History -Force -ErrorAction SilentlyContinue
Set-Alias reload Invoke-ReloadProfile -Force -ErrorAction SilentlyContinue
#endregion
