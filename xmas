<#	
	display a colorful Christmas countdown prompt
	[♫♪Christmas in 18.15:22:08֍♦] PS C:\> 
	This should work in the console with a True Type font and
	the Powershell ISE
	this prompt requires a TrueType font
	you would put this in your profile script so that it
	only runs in December 1-24
	#>
	if((Get-Date).Month -eq12-AND(Get-Date).Day -lt25) {
	#load the Christmas prompt 
	FunctionPrompt{
	#get current year
	$year=(Get-Date).year
	#get a timespan between Christmas for this year and now
	$time=[datetime]"25 December $year"-(Get-Date)
	#turn the timespan into a string and strip off the milliseconds
	$timestring=$time.ToString().Substring(0,11)
	#get random string of decorative characters
	$myChars="♫","♪","♦","*","֍"
	$front=-join($myChars|Get-Random-count 2) 
	#-join (14,15,42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
	$back=-join($myChars|Get-Random-count 2)
	#-join (14,15,42 | Get-Random -Count 2 | Foreach { $_ -as [char] })
	$text="[{0}Christmas in {1}{2}]"-f$front,$timestring,$back
	#get each character in the text and randomly assign each a color
	$text.tocharArray() |ForEach-Object{
	$i=Get-Random-Minimum 1-Maximum 20
	switch($i) {
	{$i-le20-and$i-gt15} { $color="Red"}
	{$i-le16-and$i-gt10} { $color="Green"}
	{$i-le10-and$i-gt5}{ $color="DarkGreen"}
	default{$color="White"}
	}
	#write each colorized character
	Write-Host$_-nonewline -foregroundcolor $color
	} #foreach
	#the function needs to write something to the pipeline
	"PS $($executionContext.SessionState.Path.CurrentLocation)$('>'*($nestedPromptLevel+1))"
	} #end function
	} #If December
