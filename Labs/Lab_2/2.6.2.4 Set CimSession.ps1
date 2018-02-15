$cs = New-CimSession 2012R2-MS, 2012R2-DC –Credential (Get-Credential)

Set-Volume –CimSession $cs –DriveLetter C –NewFileSystemLabel 'PowerShell'

Get-DnsClientServerAddress –CimSession $cs |
   Where ServerAddresses –like '*.*' |
   Set-DnsClientServerAddress –ServerAddresses @('10.0.1.200')

Register-DnsClient –CimSession $cs

Remove-CimSession $cs
