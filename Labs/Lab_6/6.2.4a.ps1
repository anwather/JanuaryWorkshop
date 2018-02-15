$ErrorActionPreference = SilientlyContinue

Function function1 {
    Trap {"Error trapped"}
    NonsenseString
    "Function1 was completed"
}

cls
Function1
"Script Completed"