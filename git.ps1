[string]$GitPath = $null

<#

.SYNOPSIS

Initializes Git support in the current session.


.DESCRIPTION

The Initialize-Git function searches for Git and stores the path to git.exe in the current session.
This function must be called before invoking other functions that require access to the Git command line.


.EXAMPLE

Searches for Git and stores the path to git.exe in the current session.

Initialize-Git

#>
function Initialize-Git
{
    $Global:GitPath = $null

    $gitPath = Join-Path (Get-ProgramFilesX86Directory) Git\bin\git.exe

    if (!(Test-Path $gitPath))
    {
        Write-Error "$gitPath not found. Please install Git for Windows."
        return
    }

    $Global:GitPath = $gitPath
}