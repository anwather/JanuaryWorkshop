$sb = {
    Get-DhcpServerv4Scope
    Get-DhcpServerv4OptionValue
}
Invoke-Command -ComputerName 2012R2-MS -ScriptBlock $sb
