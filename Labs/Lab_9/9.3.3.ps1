$Computers = “2012R2-MS”, “2012R2-DC”, “WIN8-WS”

workflow Test-SequenceInlineScriptWF {
  
Parallel 
{

Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object PSComputerName, Version, BuildNumber

    Sequence 
    {
    $disk = Get-CimInstance -Query "Select freespace,size from Win32_LogicalDisk Where DeviceID='C:'"
                             
        InlineScript 
        {    
        $percentFree = [Math]::Round($(($using:disk.freespace / $using:disk.size) * 100),2)
        "$PSComputerName : $percentFree %"
        }              
    } 
  }   
}
