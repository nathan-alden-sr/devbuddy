[string]$GitPath = $null

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