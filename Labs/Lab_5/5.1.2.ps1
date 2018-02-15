#5.1.2.ps1
Function Get-WindowsUpdates($Path, $simpletext, $pattern)
{
    $windowsUpdateLog = Get-Content $Path
    $result = @()
    ForEach ($line in $windowsUpdateLog)
    {
        $outObject = "" | Select-Object updateDescription, installDate
        If ($line.Contains($simpletext))
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
