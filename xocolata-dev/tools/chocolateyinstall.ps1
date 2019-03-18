$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$nuspecDir = "$(Split-Path -parent $toolsDir)"
Write-Host "tooldir:$toolsDir"
Write-Host "PSScriptRoot:$PSScriptRoot"
Write-Host "packageFolder:$packageFolder"
Write-Host "env.packageFolder:$env:packageFolder"
Write-Host ""
Write-Host "nuspecDir:$nuspecDir"

$pp = Get-PackageParameters
Write-Output "pp:$($pp|Format-Table|Out-String)"


$packageConfig=Get-Content (Join-Path $toolsDir "packageConfig.json") | ConvertFrom-Json
Write-Output "packageConfig:$($packageConfig.envVars|Format-List|Out-String)"



Start-Sleep 100
generate a error