$ErrorActionPreference = SilientlyContinue

Function function3 {
    Try {NonsenseString}
    Catch {"Error trapped inside function";Throw}
    "Function3 was completed"
}

cls
Try{Function3}
Catch {"Internal Function error re-thrown: $($_.ScriptStackTrace)"}
"Script Completed"