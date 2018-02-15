#5.1.2.13.ps1
$simpletext="Windows successfully installed the following update:"
$pat1="([^\n]+\}\t)"
$pat2="(?<PatchDate>\d{4}-\d{2}-\d{2})" 
$pat3="([^\n]+" + $simpletext + "\s)"
$pat4="(?<PatchText>[^\n]+)"

$pattern = $pat1 + $pat2 + $pat3 + $pat4

#$windowsUpdateLogPath = Join-Path $env:SystemRoot WindowsUpdate.log
$windowsUpdateLogPath = "C:\PShell\Labs\Lab_5\WindowsUpdate.log"

Get-WindowsUpdates $windowsUpdateLogPath $simpletext $pattern
