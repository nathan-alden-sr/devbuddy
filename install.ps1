#requires -version 3

Set-StrictMode -Version latest

Remove-Module DevBuddy -ErrorAction SilentlyContinue

$devBuddyModuleDirectory = "$HOME\Documents\WindowsPowerShell\Modules\DevBuddy"

if (Test-Path $devBuddyModuleDirectory)
{
    "Replacing DevBuddy module..."

    [System.IO.Directory]::Delete($devBuddyModuleDirectory, $true)
}
else
{
    "Installing DevBuddy module..."
}

Start-Process robocopy.exe -ArgumentList `"$PSScriptRoot`",`"$devBuddyModuleDirectory`",/E,/XD,.git -WindowStyle Hidden -Wait

Import-Module DevBuddy

"Available commands:"

Get-Command -Module DevBuddy