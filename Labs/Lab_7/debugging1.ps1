#debugging1.ps1
$cpu=100
$aaa="Windows"

function Step-Over() {
  $other = 6*6
  $profit=1024
  $cpu = 0
  $cpu
}

function Step-Into() {
  $other = 7*7
  $profit=32767
  $cpu = 1
  $cpu
}

function Step-Out() {
  $other=8*8
  $profit=[math]::Pow(2,32)
  $cpu = 2
  $cpu
}


$cpu=Step-Over
$cpu=Step-Into
$cpu=Step-Out
$cpu
Test-Connection -ComputerName "." -Quiet -Count 1 
Write-Host "Script Completed!"
