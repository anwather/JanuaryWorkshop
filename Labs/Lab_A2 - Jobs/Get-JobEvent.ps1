$myJob2 = Start-Job -ScriptBlock {Get-WinEvent -LogName application -MaxEvents 1000} 

$Action = {
$wsh = New-Object -ComObject wscript.shell

if ($event.Sender.State –eq “Completed”) {
$wsh.Popup(
"Job Name: $($event.SourceIdentifier)
Job State: $($event.Sender.State)
Command: $($event.Sender.Command)
Duration: $(($event.Sender.PSEndTime - $event.Sender.PSBeginTime).Seconds) seconds"
)
Unregister-Event -SourceIdentifier $myJob2.Name
}
else
{
$wsh.Popup(
"Job Name: $($event.SourceIdentifier)
Job State: $($event.Sender.State)"
)
}
}

Register-ObjectEvent -InputObject $myJob2 -EventName StateChanged -SourceIdentifier $myJob2.Name -Action $Action