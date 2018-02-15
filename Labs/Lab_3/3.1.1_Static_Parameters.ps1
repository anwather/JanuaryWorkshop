break

Test-NetConnection -ComputerName 2012r2-dc -Port 389
Test-NetConnection -ComputerName 2012r2-dc -Port 5000

Measure-Command -Expression {Test-NetConnection -ComputerName 2012r2-dc -Port 389}
Measure-Command -Expression {Test-NetConnection -ComputerName 2012r2-dc -Port 5000}

$tcp = New-Object System.Net.Sockets.TcpClient
$tcp | gm
$tcp.Connect('2012r2-dc',389)
$tcp.Connected
$tcp.Close()

$tcp = New-Object System.Net.Sockets.TcpClient
$tcp.Connect('2012r2-dc',5000)
$tcp.Connected

$tcp = New-Object System.Net.Sockets.TcpClient
Measure-Command -Expression {$tcp.Connect('2012r2-dc',5000)}



$tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect("2012R2-DC",5000,$null,$null)
$asyncResult = $connection.AsyncWaitHandle.WaitOne(1000,$false)
"2012R2-DC : 5000 : $asyncResult"



function Test-Port {

Param($HostName, $TcpPort, $MsTimeOut)

$tcpClient = New-Object System.Net.Sockets.TcpClient
$connection = $tcpClient.BeginConnect($HostName,$TcpPort,$null,$null)
$asyncResult = $connection.AsyncWaitHandle.WaitOne($MsTimeOut,$false)

"$HostName : $TcpPort : $asyncResult"
}


Test-Port -HostName 2012R2-DC -TcpPort 5000 -MsTimeOut 500
Test-Port 2012R2-DC -TcpPort 2000 -MsTimeOut 3000
Test-Port 389 2012R2-DC 10000
Test-Port 2012R2-EX 5000 10000

