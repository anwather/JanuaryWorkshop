#Workflow1.ps1
Workflow test-seq {
 Parallel {
   Sequence {
     $x='CMD'
     Start-Process cmd.exe
     Get-Process -Name cmd
   }
   Sequence {
     $y='NotePad!'
     Start-Process NotePad.exe
     Get-Process -name NotePad
   }
 }
}