#edited for clarity. 
function prompt {
$message = "$([char]9827) Happy St. Patricks Day!! $([char]9827) "
write-host $message -ForegroundColor green -NoNewline
"$((Get-Location).Path)>"
}
