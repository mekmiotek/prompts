# Set Powershell Prompt
function prompt {
    $currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

    # ANSI escape codes for color formatting
    $blue = "`e[34m"
    $green = "`e[32m"
    $yellow = "`e[33m"
    $resetColor = "`e[0m"

    # Christmas message and colors
    # Get current year
    $year = (Get-Date).Year
    # Get a timespan between Christmas for this year and now
    $time = [datetime]"25 December $year" - (Get-Date)
    # Turn the timespan into a string and strip off the milliseconds
    $timestring = $time.ToString().Substring(0, 11)
    # Get random string of decorative characters
    $front = -join (14, 15, 42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
    $back = -join (14, 15, 42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
    $text = "[{0}Christmas in {1}{2}]" -f $front, $timestring, $back

    # Get each character in the text and randomly assign each a color
    $coloredText = $text.ToCharArray() | foreach {
        $i = Get-Random -Minimum 1 -Maximum 20
        switch ($i) {
            { $i -le 20 -and $i -gt 15 } { $color = "Red" }
            { $i -le 16 -and $i -gt 10 } { $color = "Green" }
            { $i -le 10 -and $i -gt 5 } { $color = "DarkGreen" }
            default { $color = "White" }
        }

        # Write each colorized character
        Write-Host $_ -NoNewline -ForegroundColor $color
    }

    $(if (Test-Path variable:/PSDebugContext) { "$($blue)[DBG]: $($resetColor)" }
        elseif($principal.IsInRole($adminRole)) { "$($green)[ADMIN]: $($resetColor)" }
        else { '' }
    ) + "$($blue)[$(Get-Date -f 'hh:mm:ss tt')] $($resetColor)" +
        "$($green)$currentuser $($resetColor)" +
        "$($yellow)$(Get-Location) $($resetColor)" +
        $coloredText +
        $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
}
