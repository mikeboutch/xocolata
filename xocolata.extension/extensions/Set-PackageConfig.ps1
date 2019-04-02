$ErrorActionPreference = 'Stop'

function Set-PackageConfig{
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $packageFolder=$env:packageFolder
        $toolsDir = Join-Path $env:packageFolder "tools"
        Write-Debug "tooldir:$toolsDir"
        Write-Debug "packageFolder:$env:packageFolder"
        Write-Debug "packageParameters = $env:chocolateyPackageParameters"
        
        $pp = Get-PackageParameters
        Write-Debug "pp:$($pp|Format-Table|Out-String)"


        $pc = Get-Content (Join-Path $toolsDir "PackageConfig.json") | ConvertFrom-Json
        Write-Debug "PackageConfig(pc):$($pc.'envVars'|Format-List|Out-String)"

        $envVars = [ordered]@{ }
    }
    
    process {


        $targetConfig = "$($pc| Select-Object -ExpandProperty 'targetConfig')" 
        if ($pp['targetConfig'] -is [string]) {
            $targetConfig = $pp['targetConfig']
        }

        Write-Output "Getting default for target config ""$($targetConfig)"" env vars..."
        $pc.envVars.PSObject.Properties | ForEach-Object {
    
            if ($_.MemberType -eq 'NoteProperty') {
                if ($_.TypeNameOfValue -eq 'System.String') {
                    $envVars["$($_.Name)"] = "$($_.Value)"
                }
                elseif ($_.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {
                    $Name = "$($_.Name)"
                    #$Value=($_.Value.PSObject.Properties)[$targetConfig].Value
                    $Value = ($_.Value.PSObject.Properties | Where-Object -Property Name -like $targetConfig).Value
                    if ($Value -is [String]) {
                        $envVars[$Name] = "$Value"
                    }
                    else {
                        throw "targetConfig ""$targetConfig"" not found in pc.json"
                    }
                }
            }
        }
        Write-Debug "$($envVars|Format-Table|Out-String)"

        Write-Output "Setting env variables from current env and parameters , to the current process env..."
        $CurrEnv = $false
        if ($pc.getFromCurrEnv) { $CurrEnv = $true }
        if ($pc.ignoreCurrEnv) { $CurrEnv = $false }
        if ($pp.getFromCurrEnv) { $CurrEnv = $true }
        if ($pp.ignoreCurrEnv) { $CurrEnv = $false }

        ## add force ignoreCurrEnv on BackgroundMode
        #if ($CurrEnv) {Write-Output "Get from Current Env"} 
        foreach ($k in $($envVars.keys)) {
            if ( $CurrEnv -and (Test-Path "env:$k") ) {
                #Write-Output "$($envVars["$k"]) = $(((get-item env:$k).Value))"
                $envVars["$k"] = (Get-Item env:$k).Value
            }
            if ($pp["$k"] -is [string]) {
                $envVars["$k"] = $pp["$k"] 
            }
            Install-ChocolateyEnvironmentVariable $k $envVars["$k"] Process
        }
        Write-Debug "$($envVars|Format-Table|Out-String)"

        Write-Debug "Finding envScope"
        try {
            $envScope = "$($pc| Select-Object -ExpandProperty 'envScope')"
            ## force ignore User scope on Background Mode
        }
        catch {
            $envScope = 'Machine'    
        }
        if ($pp.envScope -is [string]) {
            $envScope = $pp.envScope
        } 
        if ($envScope -like 'Machine') { $envScope = 'Machine' } 
        elseif ($envScope -like 'User') { $envScope = 'User' } ## ignore on Background Mode
        elseif ($envScope -like 'Batch') { $envScope = 'Batch' }    
        else {
            throw "Wrong envScope"
        }
 
        Write-Output "Applying env variables to $envscope" 
        if ($envScope -ne 'Batch') {
            foreach ($k in $($envVars.keys)) {
                Install-ChocolateyEnvironmentVariable $k $envVars["$k"] $envScope 
            }
        }
        $envBatchFile = Join-Path $env:packageFolder $(Join-Path "tools" "$env:ChocolateyPackageName.setEnv.cmd" )
        $defaultEnvBatchFile = ($pc | Where-Object -Property Name -eq 'envBatchFile').Value
        if ($DefaultEnvBatchFile -is [String]) {
            $envBatchFile = "$defaultEnvBatchFile"
        }
        if ($pp['envBatchFile'] -is [String]) {
            $envBatchFile = $pp['envBatchFile']
        }
        try {
            $envBatchContent = @(Get-Content -Path $envBatchFile)
            Write-Debug "'$envBatchFile'file exist!"
        }
        catch {
            Write-Debug "'$envBatchFile' file dont exist!"
            [String[]]$envBatchContent = @()
            $envBatchContent += '@echo off'
        }
        $envBatchWriteStream = [System.IO.StreamWriter]::new( $envBatchFile )
        foreach ($k in $($envVars.keys)) {
            $re='^\s*SET\s+'+[regex]::Escape($k)+'=.*'
            $line="SET $k=$($envVars["$k"])"
            #write-output "$re : $line"
            if (($envBatchContent) -imatch $re) {
                #Write-Output "Find it $k $re "
                $envBatchContent=@($envBatchContent | ForEach-Object { $_ -replace $re, $line })
            }
            else {
                #Write-OuTput "add line $line"
                $envBatchContent += $line
            }
        
        }
        Write-Output "Writting the set env vars batch file : $envBatchFile "
        $envBatchContent | ForEach-Object { $envBatchWriteStream.WriteLine( $_ ) }
        $envBatchWriteStream.Close()
    }
    
    end {
    }
}