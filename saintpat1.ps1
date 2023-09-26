#edited for clarity. 
function prompt {
$message = "$([char]9827) Éirinn go Brách $([char]9827) "
write-host $message -ForegroundColor green -NoNewline
"$((Get-Location).Path)>"
}
