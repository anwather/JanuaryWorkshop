$ComputerName = "2012R2-MS"
$cred = Get-Credential -Credential Contoso\Administrator

# Install OData Feature
Install-WindowsFeature -Name ManagementOdata -ComputerName $ComputerName

# Install Required IIS Features
Install-WindowsFeature -Name  WCF-HTTP-Activation45 -IncludeAllSubFeature -IncludeManagementTools -ComputerName $ComputerName
Install-WindowsFeature -Name  Web-Basic-Auth,Web-Windows-Auth,Web-Mgmt-Console,Web-Mgmt-Tools,Web-Scripting-Tools,Web-Mgmt-Service -IncludeAllSubFeature -ComputerName $ComputerName
Install-WindowsFeature -Name Web-Mgmt-Compat -IncludeAllSubFeature -IncludeManagementTools -ComputerName $ComputerName