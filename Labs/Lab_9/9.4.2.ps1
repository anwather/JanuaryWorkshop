workflow Test-SuspendWF
{
    While ($true) 
    {
    	$cookedValue = (Get-counter '\Process(powershell)\% Processor Time' -SampleInterval 1).countersamples.cookedvalue 

    	If ($cookedValue -gt 0) 
    	{
            "$([math]::round(($cookedValue / $env:NUMBER_OF_PROCESSORS),2)) %"
    	}
    	Else
    	{
            Suspend-Workflow
    	}
    }
}
