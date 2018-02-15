#5.1.2-complete.ps1
Function Get-WindowsUpdates($Path, $simpletext, $pattern)
{
    $windowsUpdateLog = Get-Content $Path
    $result = @()
    Foreach ($line in $windowsUpdateLog)
    {
        $outObject = "" | Select-Object updateDescription, installDate
        if ($line.Contains($simpletext))
        {
            If ($line -match $pattern ) {
              $outObject.updateDescription = $matches.PatchText
              $outObject.installDate       = $matches.PatchDate
              $result += $outObject
            }
        }
    }
    $result
}
$simpletext="Windows successfully installed the following update:"
$pat1="([^\n]+\}\t)"
$pat2="(?<PatchDate>\d{4}-\d{2}-\d{2})" 
$pat3="([^\n]+" + $simpletext + "\s)"
$pat4="(?<PatchText>[^\n]+)"

$pattern = $pat1 + $pat2 + $pat3 + $pat4

#$windowsUpdateLogPath = Join-Path $env:SystemRoot WindowsUpdate.log
$windowsUpdateLogPath = "C:\PShell\Labs\Lab_5\WindowsUpdate.log"

Get-WindowsUpdates $windowsUpdateLogPath $simpletext $pattern
