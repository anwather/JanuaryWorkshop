#assert-xDHCPdeploy.ps1
#requires -RunAsAdministrator

Configuration xDHCPDeploy 
{

    Node ("2012R2-MS","WIN8-WS")
    {

      Archive xDHCPzip {
        Ensure = "Present"
        Path = "\\2012R2-MS\DSCResources\xDHCP.zip"
        Destination = "$PSHOME\Modules"
      }
    }
}

xDHCPdeploy -OutputPath $PSScriptRoot\xDHCPdeploy
Start-DscConfiguration -path $PSScriptRoot\xDHCPdeploy -Wait -Verbose
