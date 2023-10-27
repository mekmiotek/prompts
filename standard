#Set Powershell Prompt
function prompt {
  $currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
  $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
    elseif($principal.IsInRole($adminRole)) { "[ADMIN]: " }
    else { '' }
  ) + "[$(Get-Date -f 'hh:mm:ss tt')] " + "$currentuser " + $(Get-Location) +
    $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
