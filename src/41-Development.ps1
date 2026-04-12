# PowerConfig Development Tools - Standardized
# Specialized logic for Dev Environments

#region GIT (Logic)
function Invoke-GitStatus { git status -sb }
function git-add { git add @args }
function git-add-all { git add --all }
function git-commit { git commit @args }
function git-commit-message { git commit -m @args }
function git-checkout { git checkout @args }
function git-checkout-branch { git checkout -b @args }
function git-log { git log --oneline --graph --decorate @args }
function git-pull { git pull @args }
function git-push { git push @args }
#endregion

#region PYTHON
function Invoke-Venv {
    param([string]$Name = "venv")
    python -m venv $Name
}

function New-PythonVenv {
    Invoke-Venv venv
    .\venv\Scripts\Activate.ps1
}
#endregion

#region DOCKER Helpers
function docker-ps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function docker-images { docker images }
#endregion

#region CLOUD
function az-login { az login }
function az-group { az group @args }
#endregion
