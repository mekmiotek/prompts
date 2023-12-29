# Set Powershell Prompt
function prompt {
<# Prompt contains Date,Time,Computername,Location#>
    $computerName = $env:COMPUTERNAME  # Get the computer name
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
    ) + "$($red)$(Get-Date -f 'MM/dd/yyyy') $($white)$(Get-Date -f 'hh:mm:ss tt') $($resetColor)" +
        "$($white)$computerName $($resetColor)" +  # Display computer name instead of username
        "$($blue)$(Get-Location) $($resetColor)" +
        $(if ($NestedPromptLevel -ge 1) { "$($blue)>>$($resetColor)" }) + "$($blue)$('> ')"
}
