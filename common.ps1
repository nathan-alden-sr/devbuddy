function Convert-SecureStringToString
{
    <#

    .SYNOPSIS

    Converts a System.Security.SecureString to a non-secure string.


    .DESCRIPTION

    The Convert-SecureStringToString function converts a System.Security.SecureString to a non-secure string.


    .PARAMETER $SecureString

    A System.Security.SecureString object.


    .EXAMPLE

    Convert a System.Security.SecureString object to its non-secure string representation.

    Convert-SecureStringToString (Read-Host "Enter a password:" -AsSecureString)

    #>
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
    <#

    .SYNOPSIS

    Gets the Program Files directory that contains 32-bit applications.


    .DESCRIPTION

    The Get-ProgramFilesX86Directory function gets the Program Files directory that contains 32-bit applications.
    On 32-bit Windows, this directory will usually be "C:\Program Files".
    On 64-bit Windows, this directory will usually be "C:\Program Files (x86)".


    .EXAMPLE

    Gets the Program Files directory that contains 32-bit applications.

    Get-ProgramFilesX86Directory

    #>
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
    <#

    .SYNOPSIS

    Matches content against a regular expression and outputs only the matches.


    .DESCRIPTION

    The Select-MatchesInContent function matches content against a regular expression and outputs only the matches.
    The matches, not the content, are outputted.


    .PARAMETER $Path

    The path whose content is to be matched.


    .PARAMETER $Pattern

    A regular expression.


    .EXAMPLE

    Selects matches for content output matching the pattern "Hello, world!".

    Write-Output Red,Blue,Orange,Blue | Set-Content Colors.txt
    Select-MatchesInContent Colors.txt Blue
    Remove-Item Colors.txt

    #>
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
    <#

    .SYNOPSIS

    Matches content against a regular expression and replaces the content using a replacement expression.


    .DESCRIPTION

    The Set-MatchReplacementsInContent function matches content against a regular expression and replaces the content using a replacement expression.


    .PARAMETER $Path

    The path whose content is to be matched.


    .PARAMETER $Pattern

    A regular expression.


    .PARAMETER $Replacement

    A replacement expression.


    .EXAMPLE

    Write-Output Red,Blue,Orange,Blue | Set-Content Colors.txt
    Set-MatchReplacementsInContent Colors.txt Blue Green
    Get-Content Colors.txt
    Remove-Item Colors.txt

    #>
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

function Wait-True
{
    <#

    .SYNOPSIS

    Repeatedly evalutes a script block until it returns $true.


    .DESCRIPTION

    The Wait-True function repeatedly evalutes a script block until it returns $true.
    Optionally, evaluation may be retried with a delay.
    Exceptions count as a failure to return $true.


    .PARAMETER $ScriptBlock

    A script block.


    .PARAMETER $DelayInMilliseconds

    A delay, in milliseconds, between each attempt.

    If unspecified, the delay will be 1000 milliseconds.


    .PARAMETER $MaximumAttempts

    The maximum number of times to invoke the function.

    If unspecified, the script block will only be evaluated once.


    .EXAMPLE

    Wait-True { (Get-Date).Minute % 2 -eq 0 } 1000 120

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ScriptBlock,
        [Parameter(Mandatory=$true)]
        [int]$DelayInMilliseconds = 1000,
        [int]$MaximumAttempts = 1)

        [int]$attempts = 0

    while (++$attempts -le $MaximumAttempts)
    {
        try 
        {
            if ($ScriptBlock.Invoke() -eq $true)
            {
                return $true
            }
            else
            {
                Start-Sleep -Milliseconds $DelayInMilliseconds
            }
        }
        catch
        {
            Start-Sleep -Milliseconds $DelayInMilliseconds
        }
    }

    return $false
}