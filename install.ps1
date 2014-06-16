#requires -version 3

Set-StrictMode -Version latest

$devBuddyModuleDirectory = "$HOME\Documents\WindowsPowerShell\Modules\dev-buddy"

if (Test-Path $devBuddyModuleDirectory)
{
    [System.IO.Directory]::Delete($devBuddyModuleDirectory, $true)
}

Start-Process robocopy.exe -ArgumentList `"$PSScriptRoot`",`"$devBuddyModuleDirectory`",/E,/XD,.git -WindowStyle Hidden -Wait