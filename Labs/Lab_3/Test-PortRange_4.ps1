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

        "$HostName : $TcpPort : $asyncResult"
     }
}


function Test-PortRange {

[CmdletBinding()]

param(
$ComputerName,
$Ports,
$TimeOut = 10,
[Switch]$Progress
)
    $count = 0  

    foreach ($Port in $Ports) 
    {
        if ($Progress)
        {
            Write-Progress -Activity "Connecting to $ComputerName" -Status "Progress: $([int]($count/$Ports.count * 100))%" `
            -PercentComplete $($count/$Ports.count * 100)
        
            $count++
        }
        Test-Port -HostName $ComputerName -TcpPort $Port -MsTimeOut $TimeOut
    }
}

# Test-PortRange -ComputerName 2012R2-DC -Ports 80,81,135,445,389,5000 -Progress -TimeOut 1000 -Verbose
