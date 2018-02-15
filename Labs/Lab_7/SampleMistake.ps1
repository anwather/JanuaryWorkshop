#SampleMistake.ps1
 $TransferApprovedSuccessfully=$false
 #lots of code doing things...

 $TransferApprovedSuccessfully=$true
 # lots more code...

 if ($TransferApprovedSuccesfully -eq $true) {
  Write-Output "€100m funds transfer underway"
  # lots more code...
 }
 else {
   Write-Output "Awaiting funds."
 }
