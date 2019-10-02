$ErrorActionPreference = 'Stop'; # stop on all errors

Write-Output "loaded"
##cinst xocolata-dev --params "'/tagetConfig:local-sit3'"
$env:chocolateyPackageParameters=$env:chocolateyPackageParameter+" /targetConfig:pat "
Set-PackageConfig
Start-Sleep 1
#throw "never install"