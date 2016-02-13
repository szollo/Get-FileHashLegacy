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