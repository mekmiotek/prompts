function prompt {
    $u = (whoami).Split('\')[-1]
    $d = Split-Path $pwd -Leaf
    $h = $host.ui.RawUI
    $windowTitle = "ID $pid - $d"
    $h.windowTitle = $windowTitle
    $a = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $l = Get-History -Count 1
    if ($l) { $t = [int]($l.EndExecutionTime - $l.StartExecutionTime).TotalSeconds }
    if ($t -ge 60) { $s = [timespan]::fromseconds($t); $m, $s = $s.ToString("mm\:ss").Split(":"); $e = "m $m $s" }
    else { $e = [MATH]::Round($t, 2).ToString() + " sec" }
    Write-Host " "
    if ($a) { Write-Host ("[ELEVATED] ") -BackgroundColor DarkRed -ForegroundColor White -NoNewLine }
    Write-Host "[$u] " -ForegroundColor DarkRed -NoNewLine
    Write-Host "[$e] " -ForegroundColor Green -NoNewLine
    "> "
}
