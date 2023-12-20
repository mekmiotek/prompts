# Set Powershell Prompt
function prompt {
    $currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    # ANSI escape codes for color formatting
    $blue = "`e[34m"
    $white = "`e[97m"
    $red = "`e[91m"
    $resetColor = "`e[0m"

    $(if (Test-Path variable:/PSDebugContext) { "$($blue)[DBG]: $($resetColor)" }
        elseif($principal.IsInRole($adminRole)) { "$($red)[ADMIN]: $($resetColor)" }
        else { '' }
    ) + "$($white)$(Get-Date -f 'MM/dd/yyyy') $($blue)$(Get-Date -f 'hh:mm:ss tt') $($resetColor)" +
        "$($red)$currentuser $($resetColor)" +
        "$($white)$(Get-Location) $($resetColor)" +
        $(if ($NestedPromptLevel -ge 1) { "$($blue)>>$($resetColor)" }) + "$($blue)$('> ')"
}
