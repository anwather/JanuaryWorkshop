#Get-PSversionInfo.ps1
function Get-PSversionInfo {
# [CmdletBinding()]
  Param([string[]] $TargetComputers) 

  $HKLM = [Microsoft.Win32.RegistryHive]::LocalMachine
  $PowerShellRegistry="SOFTWARE\Microsoft\PowerShell"
  $KeyItem = "\PowerShellEngine"
  $Version = "PowerShellVersion"
  
  $OldErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = “SilentlyContinue”
#  if I cannot connect, don't show the error, just continue onto the next one.

  foreach ($computer in $TargetComputers)  {
    Write-Verbose "testing $computer"
    $available = Test-Connection -ComputerName $computer -Quiet -Count 1
    if ($available)  {
     $psVersions=$null
     Write-Debug "OpenRemoteBasekey"
     $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($HKLM,$computer)
     if ($Registry -ne $null)  {
      Write-Debug "OpenSubKey"
      $PSRoot = $Registry.OpenSubKey($PowerShellRegistry)
      if ($PSRoot.SubKeyCount -gt 0) {
       foreach ($SubKey in $PSRoot.GetSubKeyNames()) {
         $PowerShellEngineKey = "$PowerShellRegistry\$SubKey$KeyItem"
         Write-Debug "Engine Key: $PowerShellEngineKey"
         $EngineKey = $Registry.OpenSubKey($PowerShellEngineKey)
         if ($EngineKey -ne $null)  {
          [string]$vData = $EngineKey.GetValue($Version)
          if ($psVersions) { $psVersions += ", $vData" } 
          else { $psVersions += $vData } 
         }
       }
       Write-Output "$Computer : PowerShell $psVersions"
      }
     }
    }
  }
  $ErrorActionPreference = $OldErrorActionPreference
}

Get-PSVersionInfo "INVALID1","2012R2-DC","2012R2-MS","WIN8-WS","INVALID2" 