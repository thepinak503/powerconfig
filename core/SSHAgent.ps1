$env:SSH_AUTH_SOCK = "$env:USERPROFILE\.ssh\agent.sock"

function global:ssh_agent_ensure {
    if (Get-Command ssh-agent -ErrorAction SilentlyContinue) {
        $agentProc = Get-Process -Name "ssh-agent" -ErrorAction SilentlyContinue
        if (-not $agentProc) {
            Start-Process ssh-agent -WindowStyle Hidden
            Start-Sleep -Seconds 1
        }
    }
}

function global:ssh_agent_add {
    param([string]$KeyPath = "")
    ssh_agent_ensure
    if ($KeyPath) {
        ssh-add $KeyPath
    } else {
        ssh-add
    }
}

ssh_agent_ensure
