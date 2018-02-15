#assert-2012R2-MS.ps1
#requires -RunAsAdministrator

#
# Define the DSC actions we want executed on the target(s)
# 
Configuration DHCPMemberServer
{
    Param( 
          [PsCredential] $Credential
         )

    Node $AllNodes.NodeName
    {  
#
# standard DSC resource "WindowsFeature"
#
        WindowsFeature DHCP
        {
            Ensure   = "Present"
            Name     = "DHCP"
            IncludeAllSubFeature = $True
        }
#
# standard DSC resource "WindowsFeature"
#
        WindowsFeature RSAT-DHCP
        {
            Ensure   = "Present"
            Name     = "RSAT-DHCP"
            IncludeAllSubFeature = $True
        }
#
# custom resource "xDHSCPScope"
#
        xDHCPScope PowerShellScope
        {
            Ensure            = "Present"
            Name              = "PowerShell"
            ID                = "10.0.1.0"
            StartRange        = "10.0.1.10"
            EndRange          = "10.0.1.20"
            SubnetMask        = "255.255.255.0"
            LeaseDurationDays = 1
            Type              = "Dhcp"
            State             = "Active"
            DependsOn         = "[WindowsFeature]DHCP"
        }
#
# custom resource "xDHSCPOption"
#        
        xDHCPOption ContosoOption
        {
            Ensure        = "Present"
            DNSServerName = "10.0.1.200"
            DomainName    = "contoso.com"
            Router        = "10.0.1.254"
            DependsOn     = "[xDHCPScope]PowerShellScope"
        }
#
# custom resource "xDHSCPServeInDC"
#        
        xDHCPServerInDC MemberServerDhcpInDC
        {
            Ensure     = "Present"
            DNSName    = $Node.NodeName
            IPAddress  = "10.0.1.210"
            Credential = $credential
            DependsOn  = "[xDHCPOption]ContosoOption"
        }
#    
#  Credentials being passed will be encrypted, so we must use the right cert to decrypt.
#  We tell the DSC engine on the target via this LocalConfigurationManager block.
#
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }

    }
}


# Define a script block to run on the remote machine.
# This exports the DSC Client Encryption certificate public key.
# Returns the path on the target for the .cer file and also the thumbprint of the cert.
# NOTE: the authentication certificate exists and has been deployed to all servers.
#
$certConfig = {
  $certFolder = Join-Path -Path $Env:SystemDrive\ -ChildPath "PublicKeys"
  if (-Not (Test-Path -Path $certFolder) ) {
    New-Item -Path $certFolder -ItemType directory
  }
  $cert = Get-ChildItem -Force -Path Cert:\LocalMachine\My
  if (-NOT ($cert)) {write-error "CERT:\LocalMachine\My does NOT exist!"}
  $exportedCertificate = Export-Certificate -Cert $cert[0] -FilePath (Join-Path -Path $certFolder -ChildPath "EncryptionCertificate.cer")
  Return @($exportedCertificate,$cert.Thumbprint[0])
}


# Run the above scriptblock against the remote machine
$result = Invoke-Command -ComputerName 2012R2-MS.Contoso.com -ScriptBlock $certConfig

# get local temp directory
$temp = [System.IO.Path]::GetTempPath()

#
# copy the remote certificate to our local machine temp folder
# We will use this to encrypt the credentials into the generated MOF file.
#
$tempCertFilePath = Join-Path -Path $temp -ChildPath "EncryptionCertificate.cer"
$remoteCertFilePath = Join-Path -Path "\\2012R2-MS" -ChildPath $result[0].fullname.replace(":","$")
Copy-Item -FORCE -Path $remoteCertFilePath -Destination $tempCertFilePath


# define a seperate DSC ConfigurationData block containing a certificate thumbprint 
# and filepath specific to the remote machine. We use the local copy of the .cer
# to tell DSC to encrypt the credential. We also pass across the thumbprint
# to the target server, so it knows which of its keys to use to decrypt the credentials.
#
$ConfigurationData = @{
AllNodes = @(
    @{
        NodeName="2012R2-MS.Contoso.com"
        CertificateFile=$tempCertFilePath
        Thumbprint=$result[1]
     }
  )
}

#
# Create the MOF file for this specific DHCP configuration. 
# Pass in the configData block as it will be referred to for the credentials cert info.
#
DHCPMemberServer -ConfigurationData $ConfigurationData -OutputPath $PSScriptRoot\DHCPMemberServer -Credential (Get-Credential contoso\administrator)

#
# Set the local DSC Configuration to use the above configurationData block
#
Set-DscLocalConfigurationManager -Path $PSScriptRoot\DHCPMemberServer -Verbose

#
# Make it happen. Launch the DSC engine. 
# The supplied MOF Configuration block will install DHCP and its options
#
Start-DscConfiguration -path $PSScriptRoot\DHCPMemberServer -Wait -Verbose
