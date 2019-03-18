$ErrorActionPreference = 'Stop'
function Get-UserDomainContext {
    if ($env:ChocolateyUserContext){
        $env:ChocolateyUserDomainContext =$(Get-WmiObject win32_loggedonuser |Select-Object Antecedent -Unique | `
            Select-String -Pattern "Domain=""([^""]+)"".*Name=""$($env:ChocolateyUserContext)""" ).Matches.Groups[1].Value
        $env:USER_DOMAIN_CONTEXT=$env:ChocolateyUserDomainContext
        return $env:ChocolateyUserDomainContext
    } else {
        return $env:USER_DOMAIN
    }
}
