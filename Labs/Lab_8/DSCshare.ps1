$DSCshare = { 
 if (-NOT (Test-Path C:\DSCresources)) {
   New-Item C:\DSCresources -ItemType Directory
 }

$Inherit   = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$Propagate = [System.Security.AccessControl.PropagationFlags]::None
$ACE1 = New-Object system.security.AccessControl.FileSystemAccessRule("CONTOSO\Administrator","Fullcontrol",$Inherit,$Propagate,"Allow")
$ACE2 = New-Object system.security.AccessControl.FileSystemAccessRule("Everyone","Read",$Inherit,$Propagate,"Allow")


$folder=Get-Item C:\DSCresources
$ACL = $folder.GetAccessControl()
$ACL.AddAccessRule($ACE1)
$ACL.AddAccessRule($ACE2)
$folder.SetAccessControl($ACL)

New-SMBShare -Name DSCresources `
             -Path C:\DSCresources `
             -Description "DSC Resources" `
             –FullAccess "CONTOSO\Administrator" `
             -ReadAccess "Authenticated Users"
}

$result = Invoke-Command -ComputerName 2012R2-MS.Contoso.com -ScriptBlock $DSCshare

