function prompt {
    $host.UI.RawUI.ForegroundColor = Get-Random -Minimum 1 -Maximum 16
    $host.UI.RawUI.BackgroundColor = 'Black'
    Write-Host "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1))" -NoNewline
    $host.UI.RawUI.ForegroundColor = $initialForegroundColor
    $host.UI.RawUI.BackgroundColor = 'Black'
    return ' '
}

# Save the initial foreground color
$initialForegroundColor = $host.UI.RawUI.ForegroundColor
