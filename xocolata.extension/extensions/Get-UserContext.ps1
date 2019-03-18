$ErrorActionPreference = 'Stop'

function Get-UserContext{
    if ($env:ChocolateyUserContext){
        return $env:ChocolateyUserContext
    } else {
        return $env:USER_NAME
    }
}
