Function Get-FileHashLegacy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string] $FilePath
        [string] $Algorithm
        )

    # Get-FileHash equivalent
    $SHA1 = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
    $fileslist = Get-ChildItem $FilePath -Recurse -ErrorAction "SilentlyContinue" | where { ! $_.PSIsContainer }
    ForEach ($file in $fileslist) {
        try {
            $hash = [System.BitConverter]::ToString($SHA1.ComputeHash([System.IO.File]::Open($($file.fullname),`
            [System.IO.Filemode]::Open,[System.IO.FileAccess]::Read))) -replace "-",""
            [PSCustomObject]@{
            "Filename" = $file.fullname
            "SHA1" = $hash
            } #PSCustomObject
        } catch {
            Write-Warning "Error reading $($file.fullname)!"
        } #Catch
    } #ForEach
} #Function