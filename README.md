# DevBuddy

DevBuddy is a PowerShell module consisting of useful PowerShell scripts that automate many common developer tasks:

* Git 
* GitHub
* Visual Studio

# Installation

Clone the repository, then run `install.ps1`. The module will be installed to your `$HOME\Documents\WindowsPowerShell\Modules\dev-buddy` directory.

# Use

```
Import-Module dev-buddy
(Get-Module dev-buddy).ExportedCommands # See a list of exported commands
```