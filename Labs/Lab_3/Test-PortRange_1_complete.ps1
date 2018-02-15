##########################################

function Test-Port {

param(
$HostName,
$TcpPort,
$MsTimeOut
)

    if (Test-Connection -ComputerName $HostName -Count 1 -Quiet)
    {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connection = $tcpClient.BeginConnect($HostName,$TcpPort,$null,$null)
        $asyncResult = $connection.AsyncWaitHandle.WaitOne($MsTimeOut,$false)

        "$HostName : $TcpPort : $asyncResult"
    }
}

############################################
# function: Test-PortRange 
# Wraps the Test-Port function to allow
# multiple ports to be tested per machine

function Test-PortRange {

param(
$ComputerName,
$Ports,
$TimeOut = 10
)    
    #########################################

    foreach ($Port in $Ports) 
    {
        Test-Port -HostName $ComputerName -TCPPort $Port -MsTimeOut $TimeOut
    }
}

<#
Test-PortRange –ComputerName 2012R2-DC –Ports 80,389,5000,445 –TimeOut 100
Test-PortRange 2012R2-DC 80,389,5000,445 100
Test-PortRange 2012R2-DC 445..455 100
Test-PortRange –ComputerName 2012R2-DC, 2012R2-MS –Ports 80 –TimeOut 100
Test-PortRange -ComputerName 2012R2-DC -Ports 389
#>
