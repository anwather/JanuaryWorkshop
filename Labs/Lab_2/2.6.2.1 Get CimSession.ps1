$cs = New-CimSession 2012R2-MS, 2012R2-DC –Credential (Get-Credential)

Get-NetIPAddress –CimSession $cs | ft PSComputerName, InterfaceAlias, IPAddress

Get-DnsClientServerAddress –CimSession $cs | Where ServerAddresses –like ‘*.*’

Get-Volume –CimSession $cs | Select-Object * | Out-GridView

Get-PhysicalDisk –CimSession $cs | Select-Object * | Out-GridView

Remove-CimSession $cs
