Function ProcessUserFile
{
    Param($UserFile)
    
    $users = Import-Csv $UserFile

    foreach ($user in $users){
        
        Write-Host "Adding User: $($User.Name)..."

        $user | New-ADUser -Enabled $true

    }
    
    Write-Host "Processing Complete"
}