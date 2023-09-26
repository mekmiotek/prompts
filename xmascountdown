if ((Get-Date).Month -eq 12) {
  #load the Christmas prompt  
  
  Function Prompt {
   ...
  } #close prompt
} #if December



Function Prompt {
    #get current year
    $year = (Get-Date).year
    #get a timespan between Christmas for this year and now
$time=[datetime]"25 December $year" - (Get-Date)
    #turn the timespan into a string and strip off the milliseconds
    $timestring = $time.ToString().Substring(0,11)
#get random string of decorative characters
    $front = -join (14,15,42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
    $back = -join (14,15,42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
    $text="[{0}Christmas in {1}{2}]" -f $front,$timestring,$back
#get each character in the text and randomly assign each a color
    $text.tocharArray() | foreach {
$i = get-random -Minimum 1 -Maximum 20
    switch ($i) {
      {$i -le 20 -and $i -gt 15} { $color = "Red"}
      {$i -le 16 -and $i -gt 10} { $color = "Green" }
      {$i -le 10 -and $i -gt 5}{ $color = "DarkGreen"}
      default {$color = "White"}
    }
#write each colorized character
    write-host $_ -nonewline -foregroundcolor $color
    } #foreach
#the function needs to write something to the pipeline
    Write (" PS " + (Get-Location) + "> ")
} #end function
