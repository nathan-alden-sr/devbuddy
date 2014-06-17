#requires -version 3

Set-StrictMode -Version latest

Remove-Module DevBuddy -ErrorAction SilentlyContinue

$moduleDirectory = "$HOME\Documents\WindowsPowerShell\Modules\DevBuddy"

if (Test-Path $moduleDirectory)
{
    "Replacing DevBuddy module..."

    [System.IO.Directory]::Delete($moduleDirectory, $true)
}
else
{
    "Installing DevBuddy module..."
}

Start-Process robocopy.exe -ArgumentList `"$PSScriptRoot`",`"$moduleDirectory`",/E,/XD,.git -WindowStyle Hidden -Wait

Import-Module DevBuddy

"Available commands:"

Get-Command -Module DevBuddy