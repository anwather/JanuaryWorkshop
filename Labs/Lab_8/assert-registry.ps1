#assert-Registry.ps1

Configuration RegistryDeploy
{
    Node ("2012R2-MS","WIN8-WS")
    {  
       Registry RegKey
       {
          Ensure    = "Present"
          Key       = "HKEY_LOCAL_MACHINE\Software\Microsoft\PowerShell\Rocks"
          ValueName = "Region"
          ValueType = "MultiString"
          ValueData = "APAC","EMEA","LATAM","GCR"
       }
    }
}

RegistryDeploy -OutputPath $PSScriptRoot\RegistryDeploy
Start-DscConfiguration -path $PSScriptRoot\RegistryDeploy -Wait -Verbose


