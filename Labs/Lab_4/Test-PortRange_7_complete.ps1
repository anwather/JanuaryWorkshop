function Test-Port {

param(
$HostName,
$TcpPort,
$MsTimeOut
)

    if (Test-Connection -ComputerName $HostName -Count 1 -Quiet)
    {
        Write-Verbose -Message "Ping successfully sent to $HostName"

        Write-Verbose -Message "Creating TCPClient object"
        $tcpClient = New-Object System.Net.Sockets.TcpClient

        Write-Verbose -Message "Executing BeginConnect() to $HostName on Port $TcpPort"
        $connection = $tcpClient.BeginConnect($HostName,$TcpPort,$null,$null)

        Write-Verbose -Message "Setting AsyncWaitHandle timeout to $MsTimeout (ms)"
        $asyncResult = $connection.AsyncWaitHandle.WaitOne($MsTimeOut,$false)

        New-Object -TypeName PsObject -Property @{ComputerName=$HostName;Port=$TcpPort;Available=$asyncResult}
     }
}

function Test-PortRange {

[CmdletBinding()]
[OutputType([PSObject])]

Param(
[Alias("DNSHostName")]
[Alias("Name")]
[ValidateNotNull()]
[ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
$ComputerName,

[ValidateRange(1,65535)]
[Parameter(Mandatory,ParameterSetName="NoRange",ValueFromPipelineByPropertyName)]
$Ports,

[ValidateRange(10,10000)]
[Parameter(ParameterSetName="NoRange")]
[Parameter(ParameterSetName="Range")]
$TimeOut = 10,

[Switch]
$Progress,

[Parameter(ParameterSetName=”Range”)]
[Switch]
$Range
)

DynamicParam {

    if ($Range) 
    {
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName="Range"
        $attributes.Mandatory = $true
        $attributes.HelpMessage = "The startPort and endPort parameters are only available if the -Range switch parameter is specified"

        $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $startPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("StartPort", [int], $attributeCollection)    
        $endPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("EndPort", [int], $attributeCollection)    
        
        $paramDictionary = new-object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("StartPort", $startPort)
        $paramDictionary.Add("EndPort", $endPort)

        return $paramDictionary
    }
}

Begin {
}

Process {

    Foreach ($Computer in $ComputerName)
    {

    $count = 0  

    if ($Range)
    {

    $total = $PSBoundParameters.EndPort - $PSBoundParameters.StartPort

        foreach ($Port in $PSBoundParameters.StartPort..$PSBoundParameters.EndPort)
        {
            if ($Progress)
            {
                Write-Progress -Activity "Connecting to $Computer" -Status "Progress: $([int]($count/$total * 100))%" `
                -PercentComplete $($count/$total * 100)
        
                $count++
            }
            Write-Verbose "Executing Test-Port function against $Computer on Port $Port"
            Test-Port -HostName $Computer -TcpPort $Port -MsTimeOut $TimeOut
        }
    }
    else
    {

        foreach ($Port in $Ports) 
        {
            if ($Progress)
            {
                Write-Progress -Activity "Connecting to $Computer" -Status "Progress: $([int]($count/$Ports.count * 100))%" `
                -PercentComplete $($count/$Ports.count * 100)
        
                $count++
            }
            Write-Verbose "Executing Test-Port function against $Computer on Port $Port"
            Test-Port -HostName $Computer -TcpPort $Port -MsTimeOut $TimeOut
        }
      }
    }
  }
}

<#
Test-PortRange -ComputerName "2012R2-DC","2012R2-MS" -Ports 80,445,389,445,1024 |
Where-Object Available

# PORT SCANNER!
Get-ADComputer -Filter * | 
Select-Object -Property * | 
Test-PortRange -TimeOut 10 -Range -StartPort 80 -EndPort 400 -Progress | 
Where-Object Available
#>