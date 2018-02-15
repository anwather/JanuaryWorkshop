Function ProcessUserFile
{
    Param($UserFile=$(throw "ERROR:`n`tPlease specify a Comma Separated Value file that contains the user data to process`n"))
    
    Switch ($UserFile){
        {$_ -isNot [String]}{throw "ERROR: Please specify a string value for the UserFile Parameter"}
        {!(Test-Path $_)}{throw "ERROR: File not found"}
        {(Get-Item -Path $_).Extension -ne '.csv'}{throw "ERROR: Please specify a CSV file"}
        default {Write-Verbose "Validation complete"}
    }

    try{
        $users = Import-Csv $UserFile
        foreach ($user in $users){        
            Write-Host "Adding User: $($User.Name)..."
            $user | New-ADUser -Enabled $true -ErrorAction Stop
        }
    }
    Catch [System.Management.Automation.ParameterBindingException]{
        Write-Host "ERROR!" -BackgroundColor Red
        Write-Host "The CSV file provided does not contain the correct information."
        Write-Host "The CSV file must contain the following values at minimum:"
        Write-Host "`tSAMAccountName"
        Write-Host "`tName"
        Write-Host "`tPath"
        Write-Verbose $_
    }
    Catch{
        Write-Host "An unknown error occurred"
        Write-Verbose $_
    }

    Finally{        
        Write-Host "`nScript Complete" -ForegroundColor Green
    }
}