# Test-NetConnection Cmdlet
Test-NetConnection -ComputerName "2012R2-DC","2012R2-MS" -Port 389

# Allows pipeline input
"2012R2-DC","2012R2-MS" | Test-NetConnection -Port 389

# Long timeout if port in not open
"2012R2-DC","2012R2-MS" | Test-NetConnection -Port 5000

############################################################
# ~21 second timeout

Measure-Command -Expression {
Test-NetConnection -ComputerName 2012R2-DC -Port 5000
}

############################################################
# TcpClient class
# No advantage over the Test-NetConnection Cmdlet
# time out also ~21 seconds
 
Measure-Command -Expression {
$tcpClient = New-Object System.Net.Sockets.TcpClient
$tcpClient.Connect("2012R2-DC",5000)
$tcpClient.Connected 
$tcpClient.Close()
$tcpClient.Dispose()   
}

############################################################
# TcpClient class
# BeginConnect() allows a timeout (ms) to be specified

$tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect("2012R2-DC",5000,$null,$null)
[bool]$asyncResult = $connection.AsyncWaitHandle.WaitOne(1000,$false)

"2012R2-DC : 5000 : $asyncResult"

############################################################
# TcpClient class
# BeginConnect() allows a timeout (ms) to be specified

$tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect("2012R2-DC",389,$null,$null)
[bool]$asyncResult = $connection.AsyncWaitHandle.WaitOne(1000,$false)

"2012R2-DC : 389 : $asyncResult"

############################################################

# Test-Port function
# Uses input parameters and is reuseable

function Test-Port {

param(
$computerName,
$port,
$timeOut
)

$tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect($computerName,$port,$null,$null)
$asyncResult = $connection.AsyncWaitHandle.WaitOne($timeOut,$false)

"$computerName : $port : $asyncResult"
}

Test-Port -computerName 2012R2-DC -port 80 -timeOut 100

#########################################################
#

 function Test-Port {

 param(
 [string]$computerName,
 [int]$port,
 [int]$timeOut
 )

 $tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect($computerName,$port,$null,$null)
 [bool]$asyncResult = $connection.AsyncWaitHandle.WaitOne($timeOut,$false)

     if ($asyncResult)
     {
         "$computerName : $port : $asyncResult"
          $tcpClient.Dispose()
     }
     else
     {
         "$computerName : $port : $asyncResult"
         $tcpClient.Close()
         $tcpClient.Dispose()
     }
 }  

############################################################
# function: Test-PortRange 
# Wraps the Test-Port function to allow
# multiple ports to be tested per machine

function Test-PortRange {

param(
$computerName,
$startPort,
$endPort,
$timeOut
)

    function Test-Port {

    param(
    $computerName,
    $port,
    $timeOut
    )

        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect($computerName,$port,$null,$null)
        $asyncResult = $connection.AsyncWaitHandle.WaitOne($timeOut,$false)

        write-output "$computerName : $port : $asyncResult"
    }

foreach ($port in $startport..$endport) 
{
    Test-Port -computerName $computerName -port $port -timeOut $timeout
}

}

Test-PortRange -computerName 2012R2-DC -startPort 80 -endPort 400 -timeOut 10

############################################################
# function : Test-PortRange
#
# Add a dynamic parameter (ports)
# dynamic parameter only available 
# when -range param is specified

function Test-PortRange {

Param(
[Parameter(ParameterSetName="Range")]
[Parameter(ParameterSetName="NoRange")]
$computerName,

[Parameter(ParameterSetName="NoRange")]
[int[]]
$ports,

[Parameter(ParameterSetName="Range")]
[Parameter(ParameterSetName="NoRange")]
$timeOut,

[Parameter(ParameterSetName="Range")]
[switch]$range
)

DynamicParam {

    if ($range)
    {
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = "Range"
        $attributes.Mandatory = $false
        $attributes.HelpMessage = "The startPort and endPort parameters are only available if the -Range switch parameter is specified"

        $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $startPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("startPort", [int], $attributeCollection)    
        $endPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("endPort", [int], $attributeCollection)    
        
        $paramDictionary = new-object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("startPort", $startPort)
        $paramDictionary.Add("endPort", $endPort)

        return $paramDictionary
    }
}

Begin 
{ 
}

    End {
            if ($range)
            {
                foreach ($port in $PSBoundParameters.startPort..$PSBoundParameters.endPort) 
                {
                    Test-Port -computerName $computerName -port $port -timeOut $timeOut
                }
            }
            else
            {
                foreach ($port in $ports) 
                {
                    Test-Port -computerName $computerName -port $port -timeOut $timeOut
                }
            }
        }
}

# Test-PortRange -computerName 2012R2-DC -ports 80,81 -timeOut 100
# Test-PortRange -computerName 2012R2-DC -Range -startPort 455 -endPort 466

############################################################
#

 function Test-Port {

 param(
 [string]$computerName,
 [int]$port,
 [int]$timeOut
 )

 $tcpClient = New-Object System.Net.Sockets.TcpClient
 $connection = $tcpClient.BeginConnect($computerName,$port,$null,$null)
 [bool]$asyncResult = $connection.AsyncWaitHandle.WaitOne($timeOut,$false)

      if ($asyncResult)
     {
         New-Object -TypeName psobject -Property @{ComputerName=$computerName;Port=$port;Available=$asyncResult}
         $tcpClient.Dispose()
     }
     else
     {
         New-Object -TypeName psobject -Property @{ComputerName=$computerName;Port=$port;Available=$asyncResult}
         $tcpClient.Close()
         $tcpClient.Dispose()
     }
}

############################################################
# function : Test-PortRange
#
# Add Parameter validation attributes

# Add ability to bind -computerName parameter value 
# from the pipeline as well as accept string array on the
# -computerName parameter
# Add CmdletBinding, ParameterSets, Output type attribute

function Test-PortRange {

[CmdletBinding()]
[OutputType([psobject])]

Param(
[Alias("Name")]
[ValidateLength(0,15)]
[ValidateNotNull()]
[ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
[Parameter(ValueFromPipeline,ParameterSetName="Range",Mandatory,Position=1)]
[Parameter(ValueFromPipeline,ParameterSetName="NoRange",Mandatory,Position=1)]
[string[]]
$computerName,

[ValidateRange(1,65535)]
[Parameter(ParameterSetName="NoRange")]
[int[]]
$ports,

[ValidateRange(100,10000)]
[Parameter(ParameterSetName="Range")]
[Parameter(ParameterSetName="NoRange")]
$timeOut = 100,

[Parameter(ParameterSetName="Range")]
[switch]
$range
)

DynamicParam {

    if ($range)
    {
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = "Range"
        $attributes.Mandatory = $false
        $attributes.HelpMessage = "The startPort and endPort parameters are only available if the -Range switch parameter is specified"

        $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $startPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("startPort", [int], $attributeCollection)    
        $endPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("endPort", [int], $attributeCollection)    
        
        $paramDictionary = new-object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("startPort", $startPort)
        $paramDictionary.Add("endPort", $endPort)

        return $paramDictionary
    }
}

Begin {   
}

    Process 
    {
        foreach($computer in $computerName)
        { 

        $count = 0   
              
            if ($Range)
            {

            $total = $PSBoundParameters.endPort - $PSBoundParameters.startPort

                foreach ($port in $PSBoundParameters.startPort..$PSBoundParameters.endPort) 
                {                          
                    Write-Progress -Activity "Connecting to $computer" -Status "Progress: $([int]($count/$total * 100))%" `
                    -PercentComplete $($count/$total * 100)

                    Test-Port -computerName $computer -port $port -timeOut $timeOut
                    $count++
                }
            }
            else
            {

            $total = $ports.count

                foreach ($port in $ports) 
                {
                Write-Progress -Activity "Connecting to $computer" -Status "Progress: $([int]($count/$total * 100))%" `
                -PercentComplete $($count/$total * 100)

                Test-Port -computerName $computer -port $port -timeOut $timeOut
                $count++
                }
            }
        }             
    }
}

# Test-PortRange -range -startPort 389 -endPort 489 -computerName "2012R2-DC","2012R2-MS" | where available
# "2012R2-DC","2012R2-MS" | Test-PortRange -ports 80,81 -timeout 1000
# "2012R2-DC","2012R2-MS" | Test-PortRange -Range -startPort 455 -endPort 466 

############################################################

 function Test-Port {

 param(
 [string]$computerName,
 [int]$port,
 [int]$timeOut
 )

 Write-Verbose "Creating instance of [System.Net.Sockets.TcpClient]"
 $tcpClient = New-Object System.Net.Sockets.TcpClient

 Write-Verbose "BeginConnect() executed against server: $computerName"
 $connection = $tcpClient.BeginConnect($computerName,$port,$null,$null)

 Write-Debug "`$timeOut = $timeOut (ms)"
 [bool]$asyncResult = $connection.AsyncWaitHandle.WaitOne($timeOut,$false)

     if ($asyncResult)
     {
         Write-Verbose "connected on port: $port to Server: $computerName"
         New-Object -TypeName psobject -Property @{ComputerName=$computerName;Port=$port;Available=$asyncResult}

         Write-Debug "Disposing of TcpClient object."
         $tcpClient.Dispose()
     }
     else
     {
         New-Object -TypeName psobject -Property @{ComputerName=$computerName;Port=$port;Available=$asyncResult}

         Write-Debug "Closing TcpClient object connection."
         $tcpClient.Close()

         Write-Debug "Disposing of TcpClient object."
         $tcpClient.Dispose()
     }
} 

############################################################
# function : Test-PortRange
# Add ProgressBar switch parameter
# Use cmdlet binding to specify
# 1. Default parameterset name
# 2. Turn off positional binding
# 3. Custom HelpInfoURI

function Test-PortRange {

[CmdletBinding(
               DefaultParameterSetName="Range", 
               PositionalBinding=$false
               )]

[OutputType([psobject])]

Param(
[Alias("Name")]
[ValidateLength(0,15)]
[ValidateNotNull()]
[ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
[Parameter(ValueFromPipeline,ParameterSetName="Range",Mandatory,Position=1)]
[Parameter(ValueFromPipeline,ParameterSetName="NoRange",Mandatory,Position=1)]
[string[]]
$computerName,

[ValidateRange(1,65535)]
[Parameter(ParameterSetName="NoRange")]
[int[]]
$ports,

[ValidateRange(100,10000)]
[Parameter(ParameterSetName="Range")]
[Parameter(ParameterSetName="NoRange")]
$timeOut = 100,

[Parameter(ParameterSetName="Range")]
[switch]
$range,

[switch]
$noProgress
)

DynamicParam {

    if ($range)
    {
        $attributes = new-object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = "Range"
        $attributes.Mandatory = $false
        $attributes.HelpMessage = "The startPort and endPort parameters are only available if the -Range switch parameter is specified"

        $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $startPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("startPort", [int], $attributeCollection)    
        $endPort = new-object -TypeName System.Management.Automation.RuntimeDefinedParameter("endPort", [int], $attributeCollection)    
        
        $paramDictionary = new-object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("startPort", $startPort)
        $paramDictionary.Add("endPort", $endPort)

        return $paramDictionary
    }
}

Begin 
{      
    if ($noProgress) {$ProgressPreference="SilentlyContinue"}  
}

    Process 
    {
        foreach($computer in $computerName)
        { 

        $count = 0   
              
            if ($Range)
            {

            $total = $PSBoundParameters.endPort - $PSBoundParameters.startPort

                foreach ($port in $PSBoundParameters.startPort..$PSBoundParameters.endPort) 
                {                          
                    Write-Progress -Activity "Connecting to $computer" -Status "Progress: $([int]($count/$total * 100))%" `
                    -PercentComplete $($count/$total * 100)

                    Test-Port -computerName $computer -port $port -timeOut $timeOut
                    $count++
                }
            }
            else
            {

            $total = $ports.count

                foreach ($port in $ports) 
                {
                Write-Progress -Activity "Connecting to $computer" -Status "Progress: $([int]($count/$total * 100))%" `
                -PercentComplete $($count/$total * 100)

                Test-Port -computerName $computer -port $port -timeOut $timeOut
                $count++
                }
            }
        }             
    }
}

# Test-PortRange -range -startPort 389 -endPort 489 -computerName "2012R2-DC","2012R2-MS" -Verbose
# "2012R2-DC","2012R2-MS" | Test-PortRange -range -startPort 389 -endPort 489 -noProgress
# "2012R2-DC","2012R2-MS" | Test-PortRange -range -startPort 389 -endPort 489 -Debug -noProgress
