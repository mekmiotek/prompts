<#
This may not work properly or completely in all PowerShell hosts. Because the function
relies on Get-CimInstance it will not work on Linux platforms. 
It is also admittedly not speedy as it is doing a lot of stuff, although there is an 
attempt to cache some information which gets updated every 15 minutes.
To use, dot source this script in your PowerShell profile to make it your default prompt.
Sample prompt:
┌──────────────────────────────────────────────────────────────────────────────────────┐
│CPU:01% FreeMem:15.99GB Procs:206 Free C:55.63% ▲13d 16h 20m 54s 8/22/2017 10:25:42 AM│
└──────────────────────────────────────────────────────────────────────────────────────┘
137 [v5.1.15063.502]PS>

The border around the system information will be color coded depending on the percentage
of free physical memory. The value before the date and time is the computer uptime.
The first value in the prompt will be the history ID number. The number in brackets is
the PowerShell version.
The window title will show the run time of your PowerShell session, the computername,
whether you are running as Administrator and the current location.
#>
if ($IsWindows -OR $PSEdition -eq 'Desktop') {
Function Test-IsAdministrator {  
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
    }
Function Test-IsPS32 {
        $psfilename = (Get-Process -id $pid).mainmodule.filename
        if ($psfilename -match "SysWoW64") {
            $True
        }
        else {
            $False
        }
    }
Function prompt {
#add global variable if it doesn't already exist
        if (-Not $global:LastCheck) {
            $global:LastCheck = Get-Date
            $global:cdrive = Get-CimInstance -query "Select Freespace,Size from win32_logicaldisk where deviceid='c:'"
        }
#only refresh disk information once every 15 minutes
        $min = (New-TimeSpan $Global:lastCheck).TotalMinutes
        if ($min -ge 15) {
            $global:cdrive = Get-CimInstance -query "Select Freespace,Size from win32_logicaldisk where deviceid='c:'"
            $global:LastCheck = Get-Date
        }
        $diskinfo = "{0:N2}" -f (($global:cdrive.freespace / 1gb) / ($global:cdrive.size / 1gb) * 100)
#only the get the CIM properties we need to cut down on processing time
        $cpu = (Get-CimInstance -ClassName win32_processor -property loadpercentage).loadpercentage
        #get the number of running processes
        $pcount = (Get-Process).Count
$os = Get-CimInstance -class Win32_OperatingSystem -Property LastBootUpTime, TotalVisibleMemorySize, FreePhysicalMemory
        #calculate the percentage of free physical memory
        $freeMem = $os.freephysicalmemory / 1mb
        #get uptime
        $time = $os.LastBootUpTime
        [TimeSpan]$uptime = New-TimeSpan $time $(get-date)
        #construct an uptime string e.g. 13d 15h 18m 38s
        $up = "$($uptime.days)d $($uptime.hours)h $($uptime.minutes)m $($uptime.seconds)s"
#this is the text to appear in the status box
        $text = "CPU:{0}% FreeMem:{6:n2}GB Procs:{1} Free C:{2}% {3}{4} {5}" -f $cpu.ToString().padleft(2, "0"), $pcount, $diskinfo, ([char]0x25b2), $up, (Get-Date -format G), $FreeMem
#display prompt data in color based on the amount of free memory
        $pctFreeMem = $os.FreePhysicalMemory / $os.TotalVisibleMemorySize
        if ($pctFreeMem -ge .70) {
            $color = "green"
        }
        elseif ($pctFreeMem -ge .30) {
            $color = "yellow"
        }
        else {
            $color = "red"
        }
#write the status box with an appropriate outline color
        Write-Host $([char]0x250c) -NoNewline -ForegroundColor $color
        Write-Host $(([char]0x2500).ToString() * $text.length ) -ForegroundColor $color -NoNewline
        Write-Host $([char]0x2510) -ForegroundColor $color
        Write-Host $([char]0x2502) -ForegroundColor $color -NoNewline
        Write-Host $text -NoNewline
        Write-Host $([char]0x2502) -ForegroundColor $color
        Write-Host $([char]0x2514) -ForegroundColor $color -NoNewline
        Write-Host $(([char]0x2500).ToString() * $text.length) -NoNewline -ForegroundColor $color
        Write-Host $([char]0x2518) -ForegroundColor $color
#get history ID
        $hid = (Get-History -count 1).id + 1
#test if running 32 bit version of PowerShell
        if (Test-IsPS32) {
            $PsArch = "(x86)"
        }
        else {
            $PSArch = $null
        }
#write a prompt to the host
        Write-Host "$hid [v$($psversiontable.psversion)]PS$PSArch$('>' * ($nestedPromptLevel + 1))" -nonewline
#set the PowerShell session time, computername and current location in the title bar
#get start time for the current PowerShell session
        #$pid is a special variable for the current PowerShell process ID
        [datetime]$psStart = (get-Process -id $pid).StartTime
    
        $ts = (Get-Date) - $psStart
        #strip off the millisecond part with Substring().  The
        #millisecond part will come after the last period
        $s = $ts.ToString()
        $elapsed = $s.Substring(0, $s.LastIndexOf(".")) 
#test if running in an elevated session
        if (Test-IsAdministrator) {
            $As = "Administrator"
        }
        else {
            #show the current user
            $as = "$($env:USERDOMAIN)\$($env:username)"
        }
#get the current location including if in a nested level
        $loc = "$($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1))"
#set the window title
        $title = "[{0}{1}{2} as {3}]  {4}" -f $elapsed, ([char]0x25ba), $env:computername, $as, $loc
        $host.ui.rawui.WindowTitle = $title
#the function's actual output is nothing
        return " "
} #close prompt function
}
else {
    throw "The functions in this script require a Windows platform."
}
