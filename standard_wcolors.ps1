# Set Powershell Prompt
function prompt {
    $currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    # ANSI escape codes for color formatting
    $blue = "`e[34m"
    $green = "`e[32m"
    $purple = "`e[35m"
    $yellow = "`e[33m"
    $red = "`e[31m"
    $resetColor = "`e[0m"

    $(if (Test-Path variable:/PSDebugContext) { "$($blue)[DBG]: $($resetColor)" }
        elseif($principal.IsInRole($adminRole)) { "$($red)[ADMIN]: $($resetColor)" }
        else { '' }
    ) + "$($purple)$(Get-Date -f 'MM/dd/yyyy') $($blue)$(Get-Date -f 'hh:mm:ss tt') $($resetColor)" +
        "$($green)$currentuser $($resetColor)" +
        "$($yellow)$(Get-Location) $($resetColor)" +
        $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}

