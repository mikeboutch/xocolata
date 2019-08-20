$ErrorActionPreference = 'Stop'; # stop on all errors

Write-Output "loaded"

Set-PackageConfig
Start-Sleep 1
#throw "never install"