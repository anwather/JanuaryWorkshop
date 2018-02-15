$Jobs = Invoke-Command -ComputerName 2012R2-DC, 2012R2-MS, WIN8-WS -ScriptBlock {Get-WinEvent -LogName System -MaxEvents 1000} –AsJob –ThrottleLimit 1

while ($Jobs.ChildJobs.JobStateInfo.State -contains "NotStarted" -or $Jobs.ChildJobs.JobStateInfo.State -contains "Running")
{
    $RunningJob = $Jobs.ChildJobs | Where-Object state -eq "Running"
    Write-Host "$($RunningJob.Location) $($RunningJob.State)" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}