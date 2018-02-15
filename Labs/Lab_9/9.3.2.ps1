################################################################################
# Task 3.3.2: Comparing serial and parallel workflow execution
################################################################################

$Computers = "2012R2-MS", "2012R2-DC", "WIN8-WS"
$Filter = @{LogName='System'; Level=3; StartTime=(Get-Date).AddDays(-7)}

workflow Serial-EventlogWF
{
param ($Computers,$HashTableFilter)

    ForEach ($Computer in $Computers) 
    {
        Get-WinEvent -PSComputerName $Computer -FilterHashtable $HashTableFilter
    }
}

workflow Parallel-EventlogWF
{
param ($Computers,$HashTableFilter)

    ForEach -Parallel ($Computer in $Computers) 
    {
        Get-WinEvent -PSComputerName $Computer -FilterHashtable $HashTableFilter
    }
}

$cred = Get-Credential Contoso\Administrator
Measure-Command -Expression {Serial-EventlogWF   -Computers $computers -HashTableFilter $Filter -PSCredential $cred} 
Measure-Command -Expression {Parallel-EventlogWF -Computers $computers -HashTableFilter $Filter -PSCredential $cred}

# Note the TotalSeconds in the measurements of each command.