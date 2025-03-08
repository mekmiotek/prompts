# Switch-Prompt.ps1

param (
    [string]$ProfileName
)

# Define enhanced original prompt functions
function Prompt-Default {
    Write-Host "?? " -NoNewline -ForegroundColor Cyan
    "PS $($executionContext.SessionState.Path.CurrentLocation)> "
}

function Prompt-Christmas {
    Write-Host "???? " -NoNewline -ForegroundColor Green
    Write-Host "Merry " -NoNewline -ForegroundColor Red
    "PS $($executionContext.SessionState.Path.CurrentLocation) HoHoHo> "
}

function Prompt-Halloween {
    Write-Host "???? " -NoNewline -ForegroundColor Orange
    Write-Host "Spooky " -NoNewline -ForegroundColor Magenta
    "PS $($executionContext.SessionState.Path.CurrentLocation) Boo> "
}

function Prompt-Birthday {
    Write-Host "???? " -NoNewline -ForegroundColor Yellow
    Write-Host "Party " -NoNewline -ForegroundColor Cyan
    "PS $($executionContext.SessionState.Path.CurrentLocation) Yay> "
}

# St. Patrick's Day prompts
function Prompt-StPatricks1 {
    $message = "$([char]9827) Éirinn go Brách $([char]9827) "
    Write-Host $message -ForegroundColor Green -NoNewline
    "PS $((Get-Location).Path)> "
}

function Prompt-StPatricks2 {
    $message = "$([char]9827) Happy St. Patrick's Day!! $([char]9827) ?? "
    Write-Host $message -ForegroundColor Green -NoNewline
    "PS $((Get-Location).Path)> "
}

# Kitchen Sink (Windows-only)
if ($IsWindows -OR $PSEdition -eq 'Desktop') {
    function Prompt-KitchenSink {
        if (-Not $global:LastCheck) {
            $global:LastCheck = Get-Date
            $global:cdrive = Get-CimInstance -Query "Select Freespace,Size from Win32_LogicalDisk where DeviceID='c:'"
        }
        $min = (New-TimeSpan $Global:LastCheck).TotalMinutes
        if ($min -ge 15) {
            $global:cdrive = Get-CimInstance -Query "Select Freespace,Size from Win32_LogicalDisk where DeviceID='c:'"
            $global:LastCheck = Get-Date
        }
        $diskinfo = "{0:N2}" -f (($global:cdrive.freespace / 1gb) / ($global:cdrive.size / 1gb) * 100)
        $cpu = (Get-CimInstance -ClassName Win32_Processor -Property LoadPercentage).LoadPercentage
        $pcount = (Get-Process).Count
        $os = Get-CimInstance -Class Win32_OperatingSystem -Property LastBootUpTime, TotalVisibleMemorySize, FreePhysicalMemory
        $freeMem = $os.FreePhysicalMemory / 1mb
        $time = $os.LastBootUpTime
        [TimeSpan]$uptime = New-TimeSpan $time $(Get-Date)
        $up = "$($uptime.days)d $($uptime.hours)h $($uptime.minutes)m $($uptime.seconds)s"
        $text = "CPU:{0}% FreeMem:{6:n2}GB Procs:{1} Free C:{2}% {3}{4} {5}" -f $cpu.ToString().PadLeft(2, "0"), $pcount, $diskinfo, ([char]0x25b2), $up, (Get-Date -Format G), $freeMem
        $pctFreeMem = $os.FreePhysicalMemory / $os.TotalVisibleMemorySize
        $color = if ($pctFreeMem -ge .70) { "Green" } elseif ($pctFreeMem -ge .30) { "Yellow" } else { "Red" }
        Write-Host $([char]0x250c) -NoNewline -ForegroundColor $color
        Write-Host $(([char]0x2500).ToString() * $text.Length) -ForegroundColor $color -NoNewline
        Write-Host $([char]0x2510) -ForegroundColor $color
        Write-Host $([char]0x2502) -ForegroundColor $color -NoNewline
        Write-Host $text -NoNewline
        Write-Host $([char]0x2502) -ForegroundColor $color
        Write-Host $([char]0x2514) -ForegroundColor $color -NoNewline
        Write-Host $(([char]0x2500).ToString() * $text.Length) -ForegroundColor $color -NoNewline
        Write-Host $([char]0x2518) -ForegroundColor $color
        $hid = (Get-History -Count 1).Id + 1
        Write-Host "$hid [v$($PSVersionTable.PSVersion)]PS$('>' * ($NestedPromptLevel + 1))" -NoNewline
        return " "
    }
}

# Network Status prompt
function Prompt-NetworkStatus {
    $up = 0x25b2 -as [char]
    $down = 0x25bc -as [char]
    if (-not $global:testHash) {
        $global:testHash = [hashtable]::Synchronized(@{Computername = $env:COMPUTERNAME; results = ""; date = (Get-Date)})
        $newRunspace = [RunspaceFactory]::CreateRunspace()
        if ($newRunspace.ApartmentState) { $newRunspace.ApartmentState = "STA" }
        $newRunspace.ThreadOptions = "ReuseThread"
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("testHash", $global:testHash)
        $psCmd = [PowerShell]::Create().AddScript({
            $computers = "dom1", "srv1", "srv2", "srv3"
            do {
                $results = $computers | ForEach-Object {
                    [PSCustomObject]@{Computername = $_.ToUpper(); Responding = Test-WSMan -ComputerName $_}
                }
                $global:testHash.results = $results
                $global:testHash.date = Get-Date
                Start-Sleep -Seconds 5
            } while ($true)
        })
        $psCmd.Runspace = $newRunspace
        [void]$psCmd.BeginInvoke()
    }
    Write-Host "[" -NoNewline
    $global:testHash.results | ForEach-Object {
        Write-Host $_.Computername -NoNewline
        if ($_.Responding) { Write-Host $up -ForegroundColor Green -NoNewline } else { Write-Host $down -ForegroundColor Red -NoNewline }
    }
    Write-Host "]" -NoNewline
    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
}

# Christmas Countdown
function Prompt-ChristmasCountdown {
    $year = (Get-Date).Year
    $time = [datetime]"25 December $year" - (Get-Date)
    $timestring = "{0:d}d {1:hh}h {1:mm}m {1:ss}s" -f $time.Days, $time
    $myChars = "??", "??", "?", "??", "??"
    $front = -join ($myChars | Get-Random -Count 2)
    $back = -join ($myChars | Get-Random -Count 2)
    $text = "[${front}Christmas in ${timestring}${back}]"
    $text.ToCharArray() | ForEach-Object {
        $i = Get-Random -Minimum 1 -Maximum 20
        $color = switch ($i) {
            {$_ -le 20 -and $_ -gt 15} { "Red" }
            {$_ -le 16 -and $_ -gt 10} { "Green" }
            {$_ -le 10 -and $_ -gt 5} { "DarkGreen" }
            default { "White" }
        }
        Write-Host $_ -NoNewline -ForegroundColor $color
    }
    " PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
}

# Admin and Time prompt
function Prompt-AdminTime {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prefix = if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
              elseif ($principal.IsInRole($adminRole)) { '[ADMIN]: ' }
              else { '' }
    Write-Host "$prefix" -NoNewline -ForegroundColor Red
    Write-Host "[$(Get-Date -f 'hh:mm:ss tt')] " -NoNewline -ForegroundColor Yellow
    "PS $($identity.Name) $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
}

# Simple Time and Location
function Prompt-TimeLocation {
    Write-Host "[$(Get-Date -f 'hh:mm:ss tt')]" -ForegroundColor Yellow -NoNewline
    " PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
}

# New Prompts from your latest submission
function Prompt-ChristmasAdminTime {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    if ($principal.IsInRole($adminRole)) { Write-Host "[ADMIN]: " -NoNewline -ForegroundColor Yellow }
    $year = (Get-Date).Year
    $time = [datetime]"25 December $year" - (Get-Date)
    $timestring = "{0:d}d {1:hh}h {1:mm}m {1:ss}s" -f $time.Days, $time
    $front = -join (14, 15, 42 | Get-Random -Count 2 | ForEach-Object { $_ -as [char] })
    $back = -join (14, 15, 42 | Get-Random -Count 2 | ForEach-Object { $_ -as [char] })
    $text = "[${front}Christmas in ${timestring}${back}]"
    $text.ToCharArray() | ForEach-Object {
        $i = Get-Random -Minimum 1 -Maximum 20
        $color = switch ($i) {
            {$_ -le 20 -and $_ -gt 15} { "Red" }
            {$_ -le 16 -and $_ -gt 10} { "Green" }
            {$_ -le 10 -and $_ -gt 5} { "DarkGreen" }
            default { "White" }
        }
        Write-Host $_ -NoNewline -ForegroundColor $color
    }
    " PS [$(Get-Date -f 'hh:mm:ss tt')] $(whoami).ToUpper() $($executionContext.SessionState.Path.CurrentLocation)> "
}

function Prompt-ANSIDateUser1 {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $blue = "`e[34m"; $white = "`e[97m"; $red = "`e[91m"; $resetColor = "`e[0m"
    $prefix = if (Test-Path variable:/PSDebugContext) { "$blue[DBG]: $resetColor" }
              elseif ($principal.IsInRole($adminRole)) { "$red[ADMIN]: $resetColor" }
              else { '' }
    "$prefix$white$(Get-Date -f 'MM/dd/yyyy') $blue$(Get-Date -f 'hh:mm:ss tt') $resetColor$red$($identity.Name) $resetColor$white$($executionContext.SessionState.Path.CurrentLocation)$resetColor$(if ($NestedPromptLevel -ge 1) { "$blue>>$resetColor" }) $blue> $resetColor"
}

function Prompt-ANSIDateUser2 {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $blue = "`e[34m"; $white = "`e[97m"; $red = "`e[91m"; $resetColor = "`e[0m"
    $prefix = if (Test-Path variable:/PSDebugContext) { "$blue[DBG]: $resetColor" }
              elseif ($principal.IsInRole($adminRole)) { "$red[ADMIN]: $resetColor" }
              else { '' }
    "$prefix$red$(Get-Date -f 'MM/dd/yyyy') $white$(Get-Date -f 'hh:mm:ss tt') $resetColor$white$($identity.Name) $resetColor$blue$($executionContext.SessionState.Path.CurrentLocation)$resetColor$(if ($NestedPromptLevel -ge 1) { "$blue>>$resetColor" }) $blue> $resetColor"
}

function Prompt-ANSIDateComputer {
    $computerName = $env:COMPUTERNAME
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $blue = "`e[34m"; $white = "`e[97m"; $red = "`e[91m"; $resetColor = "`e[0m"
    $prefix = if (Test-Path variable:/PSDebugContext) { "$blue[DBG]: $resetColor" }
              elseif ($principal.IsInRole($adminRole)) { "$red[ADMIN]: $resetColor" }
              else { '' }
    "$prefix$red$(Get-Date -f 'MM/dd/yyyy') $white$(Get-Date -f 'hh:mm:ss tt') $resetColor$white$computerName $resetColor$blue$($executionContext.SessionState.Path.CurrentLocation)$resetColor$(if ($NestedPromptLevel -ge 1) { "$blue>>$resetColor" }) $blue> $resetColor"
}

function Prompt-RandomColor {
    $initialForegroundColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = Get-Random -Minimum 1 -Maximum 16
    $host.UI.RawUI.BackgroundColor = 'Black'
    Write-Host "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1))" -NoNewline
    $host.UI.RawUI.ForegroundColor = $initialForegroundColor
    $host.UI.RawUI.BackgroundColor = 'Black'
    return ' '
}

function Prompt-SimpleAdminTime {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $prefix = if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
              elseif ($principal.IsInRole($adminRole)) { '[ADMIN]: ' }
              else { '' }
    "$prefix[$(Get-Date -f 'hh:mm:ss tt')] $($identity.Name) $($executionContext.SessionState.Path.CurrentLocation)$(if ($NestedPromptLevel -ge 1) { '>>' })> "
}

function Prompt-ANSIMultiColor {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $blue = "`e[34m"; $green = "`e[32m"; $purple = "`e[35m"; $yellow = "`e[33m"; $red = "`e[31m"; $resetColor = "`e[0m"
    $prefix = if (Test-Path variable:/PSDebugContext) { "$blue[DBG]: $resetColor" }
              elseif ($principal.IsInRole($adminRole)) { "$red[ADMIN]: $resetColor" }
              else { '' }
    "$prefix$purple$(Get-Date -f 'MM/dd/yyyy') $blue$(Get-Date -f 'hh:mm:ss tt') $resetColor$green$($identity.Name) $resetColor$yellow$($executionContext.SessionState.Path.CurrentLocation)$resetColor$(if ($NestedPromptLevel -ge 1) { '>>' })> "
}

function Prompt-ANSIChristmas {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $blue = "`e[34m"; $green = "`e[32m"; $yellow = "`e[33m"; $resetColor = "`e[0m"
    $year = (Get-Date).Year
    $time = [datetime]"25 December $year" - (Get-Date)
    $timestring = "{0:d}d {1:hh}h {1:mm}m {1:ss}s" -f $time.Days, $time
    $front = -join (14, 15, 42 | Get-Random -Count 2 | ForEach-Object { $_ -as [char] })
    $back = -join (14, 15, 42 | Get-Random -Count 2 | ForEach-Object { $_ -as [char] })
    $text = "[${front}Christmas in ${timestring}${back}]"
    $coloredText = $text.ToCharArray() | ForEach-Object {
        $i = Get-Random -Minimum 1 -Maximum 20
        $color = switch ($i) {
            {$_ -le 20 -and $_ -gt 15} { "Red" }
            {$_ -le 16 -and $_ -gt 10} { "Green" }
            {$_ -le 10 -and $_ -gt 5} { "DarkGreen" }
            default { "White" }
        }
        Write-Host $_ -NoNewline -ForegroundColor $color
    }
    $prefix = if (Test-Path variable:/PSDebugContext) { "$blue[DBG]: $resetColor" }
              elseif ($principal.IsInRole($adminRole)) { "$green[ADMIN]: $resetColor" }
              else { '' }
    "$prefix$blue[$(Get-Date -f 'hh:mm:ss tt')] $resetColor$green$($identity.Name) $resetColor$yellow$($executionContext.SessionState.Path.CurrentLocation)$resetColor $(if ($NestedPromptLevel -ge 1) { '>>' })> "
}

# Store the current profile choice
$promptConfigPath = "$HOME\prompt_config.txt"

# If no profile specified, show current profile or available options
if (-not $ProfileName) {
    if (Test-Path $promptConfigPath) {
        $current = Get-Content $promptConfigPath
        Write-Host "Current prompt profile: $current"
    }
    Write-Host "Available profiles: Default, Christmas, Halloween, Birthday, StPatricks1, StPatricks2, KitchenSink, NetworkStatus, ChristmasCountdown, AdminTime, TimeLocation, ChristmasAdminTime, ANSIDateUser1, ANSIDateUser2, ANSIDateComputer, RandomColor, SimpleAdminTime, ANSIMultiColor, ANSIChristmas"
    Write-Host "Usage: Switch-Prompt -ProfileName <profile>"
    return
}

# Switch based on profile name
switch ($ProfileName.ToLower()) {
    "default" { function global:Prompt { Prompt-Default }; "Default" | Out-File $promptConfigPath; Write-Host "Switched to Default prompt" }
    "christmas" { function global:Prompt { Prompt-Christmas }; "Christmas" | Out-File $promptConfigPath; Write-Host "Switched to Christmas prompt" }
    "halloween" { function global:Prompt { Prompt-Halloween }; "Halloween" | Out-File $promptConfigPath; Write-Host "Switched to Halloween prompt" }
    "birthday" { function global:Prompt { Prompt-Birthday }; "Birthday" | Out-File $promptConfigPath; Write-Host "Switched to Birthday prompt" }
    "stpatricks1" { function global:Prompt { Prompt-StPatricks1 }; "StPatricks1" | Out-File $promptConfigPath; Write-Host "Switched to St. Patrick's 1 prompt" }
    "stpatricks2" { function global:Prompt { Prompt-StPatricks2 }; "StPatricks2" | Out-File $promptConfigPath; Write-Host "Switched to St. Patrick's 2 prompt" }
    "kitchensink" { if ($IsWindows -OR $PSEdition -eq 'Desktop') { function global:Prompt { Prompt-KitchenSink }; "KitchenSink" | Out-File $promptConfigPath; Write-Host "Switched to Kitchen Sink prompt" } else { Write-Host "KitchenSink requires Windows" } }
    "networkstatus" { function global:Prompt { Prompt-NetworkStatus }; "NetworkStatus" | Out-File $promptConfigPath; Write-Host "Switched to Network Status prompt" }
    "christmascountdown" { function global:Prompt { Prompt-ChristmasCountdown }; "ChristmasCountdown" | Out-File $promptConfigPath; Write-Host "Switched to Christmas Countdown prompt" }
    "admintime" { function global:Prompt { Prompt-AdminTime }; "AdminTime" | Out-File $promptConfigPath; Write-Host "Switched to Admin Time prompt" }
    "timelocation" { function global:Prompt { Prompt-TimeLocation }; "TimeLocation" | Out-File $promptConfigPath; Write-Host "Switched to Time Location prompt" }
    "christmasadmintime" { function global:Prompt { Prompt-ChristmasAdminTime }; "ChristmasAdminTime" | Out-File $promptConfigPath; Write-Host "Switched to Christmas Admin Time prompt" }
    "ansidateuser1" { function global:Prompt { Prompt-ANSIDateUser1 }; "ANSIDateUser1" | Out-File $promptConfigPath; Write-Host "Switched to ANSI Date User 1 prompt" }
    "ansidateuser2" { function global:Prompt { Prompt-ANSIDateUser2 }; "ANSIDateUser2" | Out-File $promptConfigPath; Write-Host "Switched to ANSI Date User 2 prompt" }
    "ansidatecomputer" { function global:Prompt { Prompt-ANSIDateComputer }; "ANSIDateComputer" | Out-File $promptConfigPath; Write-Host "Switched to ANSI Date Computer prompt" }
    "randomcolor" { function global:Prompt { Prompt-RandomColor }; "RandomColor" | Out-File $promptConfigPath; Write-Host "Switched to Random Color prompt" }
    "simpleadmintime" { function global:Prompt { Prompt-SimpleAdminTime }; "SimpleAdminTime" | Out-File $promptConfigPath; Write-Host "Switched to Simple Admin Time prompt" }
    "ansimulticolor" { function global:Prompt { Prompt-ANSIMultiColor }; "ANSIMultiColor" | Out-File $promptConfigPath; Write-Host "Switched to ANSI Multi-Color prompt" }
    "ansichristmas" { function global:Prompt { Prompt-ANSIChristmas }; "ANSIChristmas" | Out-File $promptConfigPath; Write-Host "Switched to ANSI Christmas prompt" }
    default { Write-Host "Profile '$ProfileName' not found. See available profiles by running Switch-Prompt without arguments." }
}

# Load the prompt immediately in current session
if (Get-Item Function:\Prompt -ErrorAction SilentlyContinue) { Remove-Item Function:\Prompt }
New-Item -Path Function:\ -Name global:Prompt -Value (Get-Item "Function:Prompt-$($ProfileName.ToLower())").ScriptBlock -Force | Out-Null