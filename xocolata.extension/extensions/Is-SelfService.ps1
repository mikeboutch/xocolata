$ErrorActionPreference = 'Stop'

function Is-SelfService{
    if ($env:ChocolateyUserContext){
        return $true
    } else {
        return $false
    }
}
