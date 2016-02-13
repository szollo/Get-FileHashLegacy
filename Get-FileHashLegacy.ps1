Function Get-FileHashLegacy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [string] $Algorithm
        )
    # Get-FileHash equivalent
    $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $SHA1 = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider

    # Go through specified path
    $fileslist = Get-ChildItem $Path -Recurse -ErrorAction "SilentlyContinue" | where { ! $_.PSIsContainer }
    ForEach ($file in $fileslist) {
        try {
            if ($Algorithm -eq "SHA1") {
                # If specifying SHA1, use SHA1CryptoServiceProvider
                $hash = [System.BitConverter]::ToString($SHA1.ComputeHash([System.IO.File]::Open($($file.fullname),`
                [System.IO.Filemode]::Open,[System.IO.FileAccess]::Read))) -replace "-",""
            } #if
            elseif ($Algorithm -eq "MD5") {
                # If specifying MD5, use MD5CryptoServiceProvider
                $hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::Open($($file.fullname),`
                [System.IO.Filemode]::Open,[System.IO.FileAccess]::Read))) -replace "-",""
            } #elseif
            
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