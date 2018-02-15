$ErrorActionPreference = SilientlyContinue

Function Function2 {
    NonsenseString
    "Function2 was completed"
}

cls
Trap{"Error Trapped!"}
Function2
"Script Completed"