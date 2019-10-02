<#
 .Synopsis
    Short description
 .DESCRIPTION
    Long description
 .EXAMPLE
    Example of how to use this cmdlet
 .EXAMPLE
    Another example of how to use this cmdlet
 #>
function Kill-ProcessWithOpenHandles {
    [CmdletBinding()]
    Param
    (
        #  # Param1 help description
        [Parameter(Mandatory = $true,
            #ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $Path
    )
 
    Begin {
    }
    Process {
        if ( Test-Path $Path ) {
            $processes = Get-Process

            # Then close all processes running inside the folder we are trying to delete
            if (Test-Path -Path $Path -PathType Container) {
                $processes | Where-Object { $_.Path -like $(Join-Path $Path  '*') } | Stop-Process -Force -ErrorAction SilentlyContinue
            }
    
            # Finally close all processes with modules loaded from folder we are trying to delete
            # foreach ($lockedFile in Get-ChildItem -Path $Path -Include * -Recurse) {
            #     foreach ($process in $processes) {
            #         $process.Modules | Where-Object { $_.FileName -eq $lockedFile } | Stop-Process -Force -ErrorAction SilentlyContinue
            #     }
            # } 
            foreach ($process in $processes) {
                $process.Modules | Where-Object { $_.FileName -like $(Join-Path $Path  '*') } | Stop-Process -Force -ErrorAction SilentlyContinue
            }
        }
    }
    End {
    }
}



