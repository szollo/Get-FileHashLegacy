<#
 .SYNOPSIS
    Small backport of Get-FileHash, which works on versions of PowerShell pre-4.0

.DESCRIPTION
    This function allows one to get similar functionality of Get-FileHash on systems older than PowerShell 4.0 

.EXAMPLE
    Get-FileHashLegacy -Path "C:\Windows\system32\"

    Gets the file hash of anything below C:\Windows\system32

.EXAMPLE
    Get-FileHashLegacy -Path "C:\Windows\system32\" -Algorithm MD5

    Gets the MD5 file hash of anything below C:\Windows\system32
    
#>

Function Get-FileHashLegacy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [ValidateSet('SHA1','SHA256','SHA384','SHA512','MD5', ignorecase=$true)]
        [string] $Algorithm
        )

    # Go through specified path
    $fileslist = Get-ChildItem $Path -Recurse -ErrorAction "SilentlyContinue" | where { ! $_.PSIsContainer }
    ForEach ($file in $fileslist) {
        try {
            # Set CryptoServiceProvider depending on chosen algorithm
            $CryptoServiceProvider = New-Object -TypeName System.Security.Cryptography.$($Algorithm)CryptoServiceProvider
            $hash = [System.BitConverter]::ToString($CryptoServiceProvider.ComputeHash([System.IO.File]::Open($($file.fullname),`
            [System.IO.Filemode]::Open,[System.IO.FileAccess]::Read))) -replace "-",""

            # Format similarly to Get-FileHash default view
            [PSCustomObject]@{
            "Algorithm" = $Algorithm
            "Hash" = $hash
            "Path" = $file.fullname
            } #PSCustomObject
        
        } catch {
            Write-Warning "Error reading $($file.fullname)!"
        } #Catch
    } #ForEach
} #Function