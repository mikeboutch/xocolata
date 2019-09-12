$ErrorActionPreference = 'Stop'

function Test-SelfService{
    if ($env:ChocolateyUserContext){
        return $true
    } else {
        return $false
    }
}
