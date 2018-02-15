function Test-Port {

param(
$HostName,
$TcpPort,
$MsTimeOut
)

    if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)
    {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect($HostName,$TcpPort,$null,$null)
        $asyncResult = $connection.AsyncWaitHandle.WaitOne($MsTimeOut,$false)

        "$HostName : $TcpPort : $asyncResult"
    }
}

function Test-PortRange {

param(
$ComputerName,
$Ports,
$TimeOut = 10
)   
    $count = 0  

    foreach ($Port in $Ports) 
    {
        
        Write-Progress -Activity "Connecting to $ComputerName" -Status "Progress: $([int]($count/$Ports.count * 100))%" `
        -PercentComplete $($count/$Ports.count * 100)
        
        $count++

        Test-Port -HostName $ComputerName -TcpPort $Port -MsTimeOut $TimeOut
    }
}

# Test-PortRange -ComputerName 2012R2-DC -Ports 80,81,135,445,389,5000 -TimeOut 1000