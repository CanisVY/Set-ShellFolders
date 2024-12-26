function Set-ShellFolders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$Path
    )
    
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    
    # Validate reg path exists
    if (-not (Test-Path $RegPath)) {
        throw "Registry path not found: $RegPath"
    }


    $ShellPaths = Import-Csv $Path

    $ShellPaths | ForEach-Object {
        $props = $_

        try {       
                # Validate item property exists
            $check = Get-ItemProperty -Path $RegPath -Name $props.Name -ErrorAction Stop
            
            if($props.name -ne "{374DE290-123F-4565-9164-39C4925E467B}"){
                Write-Verbose "Found $($props.Name)"
            }
            else{
                Write-Verbose "Found Downloads ($($props.Name))"
            }
                # Change reg key
            Set-ItemProperty -Path $RegPath -Name $props.Name -Value $props.Path
            Write-Verbose "Set value $($props.Name) : $($props.Path)"

        }
        catch {
            try{
                $validate = $false
                do {    # Prompt user for to validate creation of new key
                    $response = Read-Host "Key $($props.name) not found. Create it? Yes/Y or No/Y"
                    switch ($response.ToLower()) {
                        { $_ -in 'y', 'yes' } { 
                            $validate = $true
                            break
                        }
                        { $_ -in 'n', 'no' } { 
                            throw "User declined to create key $($props.name)"
                        }
                        default { 
                            Write-Host "Please enter Yes/Y or No/N"
                        }
                    }
                } while (-not $validate)
                    # Create new reg key if validation success
                if ($validate -eq $true){
                    New-ItemProperty -Path $RegPath -Name $props.name -Value $props.path -PropertyType ExpandString -Force
                    Write-Verbose "New Shell Path key created: $($props.Name) : $($props.Path)"
                }
            }
            catch{
                Write-Warning "User refused creation of new key."
            }
        }
    }

        # Prompt to reload explorer.exe
    $reloadExplorer = $false
    do {
        $response = Read-Host "Would you like to reload explorer.exe to apply some changes? Yes/Y or No/Y"
        switch ($response.ToLower()) {
            { $_ -in 'y', 'yes' } { 
                $reloadExplorer = $true
                break
            }
            { $_ -in 'n', 'no' } { 
                $reloadExplorer = $false
                break
            }
            default { 
                Write-Host "Please enter Yes/Y or No/Y"
            }
        }
    } while (-not ($reloadExplorer -eq $true -or $reloadExplorer -eq $false))

    if ($reloadExplorer) {
        Write-Verbose "Restarting Explorer.exe..."
        Stop-Process -Name explorer -Force
        Start-Process explorer
        Write-Warning "Some changes will not take effect until next login or system restart"
    }
    else {
        Write-Warning "Changes will not take effect until next login or system restart"
    }
}
