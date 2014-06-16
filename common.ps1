function Convert-SecureStringToString
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [System.Security.SecureString]$SecureString)

    [System.IntPtr]$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

    try
    {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally
    {
        [System.Runtime.InteropServices.Marshal]::FreeBSTR($bstr)
    }
}

function Get-ProgramFilesX86Directory
{
    if ([IntPtr]::Size -eq 8)
    {
        return ${env:ProgramFiles(x86)}
    }
    else
    {
        return ${env:ProgramFiles}
    }
}

function Select-MatchesInContent
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Pattern)
    
    Get-Content $Path | ?{ $_ -match $Pattern } | %{ $Matches }
}

function Set-MatchReplacementsInContent
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        [Parameter(Mandatory=$true)]
        [string]$Replacement)

    $content = Get-Content $Path | %{ $_ -replace $Pattern,$Replacement }

    Set-Content $Path $content
}