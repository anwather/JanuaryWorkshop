$processFilterQuery = “http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Process?`$filter=(ProcessName eq 'csrss')&`$format=JSON”

$stoppedServiceQuery = “http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Service?`$filter=(Status eq 'Stopped')&`$format=JSON”

$runningServiceQuery = "http://2012r2-ms:7000/MODataSvc/Microsoft.Management.Odata.svc/Service?`$filter=(Status eq 'Running')&`$format=JSON"

(Invoke-WebRequest -Uri $processFilterQuery -Credential $adminCred).Content | 
Convertfrom-Json | 
Select-Object -ExpandProperty value |
Get-Member

(Invoke-WebRequest -Uri $processFilterQuery -Credential $adminCred).Content | 
Convertfrom-Json | 
Select-Object -ExpandProperty value 

(Invoke-WebRequest -Uri $processFilterQuery -Credential $adminCred).Content | 
Convertfrom-Json | 
Select-Object -ExpandProperty value | Format-Table -Property ProcessName, Id, HandleCount

(Invoke-WebRequest -Uri $stoppedServiceQuery -Credential $adminCred).Content | 
Convertfrom-Json | 
Select-Object -ExpandProperty value

(Invoke-WebRequest -Uri $runningServiceQuery -Credential $adminCred).Content | 
Convertfrom-Json | 
Select-Object -ExpandProperty value