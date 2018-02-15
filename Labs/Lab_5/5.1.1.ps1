#5.1.1.ps1
$pattern = '[\w.%+-]+@[A-Z-]+(\.[A-Z]{2,})+'

$text = "Email the team at ToTheCloud@contoso.com "
$text += "and also AzureMigrate@contoso.net.au "
$text += "and lastly O365team@contoso.eu"

Function MatchMe ($pattern) {
  PROCESS { $_ | Select-String -AllMatches $pattern | 
     ForEach-Object {$_.Matches.Value} }
}

Clear-Host
Write-Output ""
Write-Output "Searching: '$text'"
Write-Output "Using pattern '$pattern'"
Write-Output " "
	
$text | MatchMe $pattern
