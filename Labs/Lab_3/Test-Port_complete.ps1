############################################################
# Test-Port function
# Input parameters instead of hard-coded values

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

<#
Test-Port -HostName 2012R2-DC -TcpPort 389 -MsTimeout 10
Test-Port -HostName 2012R2-DC -TcpPort 81 -MsTimeout 10
#>