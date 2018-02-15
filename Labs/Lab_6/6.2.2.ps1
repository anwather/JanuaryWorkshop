Function ProcessUserFile
{
    Param($UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n"))
    
    Switch ($UserFile){
        {$_ -isNot [String]}{throw "ERROR: Please specify a string vaule for the UserFile Parameter"}
        {!(Test-Path $_)}{throw "ERROR: File not found"}
        {(Get-Item -Path $_).Extension -ne '.csv'}{throw "ERROR: Please specify a CSV file"}
        default {Write-Verbose "Validation complete"}
    }
    $users = Import-Csv $UserFile

    foreach ($user in $users){
        
        Write-Host "Adding User: $($User.Name)..."

        $user | New-ADUser -Enabled $true

    }
    
    Write-Host "Processing Complete"
}