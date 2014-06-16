#requires -version 3

Copy-Item $PSScriptRoot\* "$HOME\Documents\WindowsPowerShell\Modules\dev-buddy" -Recurse -Force -Exclude install.ps1