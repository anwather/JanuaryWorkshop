# Store credentials
$password = ConvertTo-SecureString -AsPlainText -String "PowerShell4" -Force
$userCred = New-Object System.Management.Automation.PSCredential("Contoso\DanPark",$password)
$adminCred = New-Object System.Management.Automation.PSCredential("Contoso\Administrator",$password)

# define Web service queries
$processQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Process"
$serviceQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Service"
$processFilterQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Process?`$filter=(ProcessName eq 'csrss')"
$stoppedServiceQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Service?`$filter=(Status eq 'Stopped')"
$runningServiceQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Service?`$filter=(Status eq 'Running')"
