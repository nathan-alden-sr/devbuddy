#requires -version 3

Set-StrictMode -Version latest

if (Get-Module dev-buddy)
{
    return
}

Push-Location $PSScriptRoot

. .\common.ps1
. .\git.ps1
. .\github.ps1
. .\github-repositories.ps1
. .\github-teams.ps1
. .\visual-studio.ps1

Pop-Location

Export-ModuleMember `
    -Function @(
        # git.ps1
        "Initialize-Git",

        # github.ps1
        "Initialize-GitHub",

        # github-repositories.ps1
        "Get-GitHubRepositories",
        "New-GitHubRepository",
        "New-LocalGitHubRepository",
        "New-LocalClonedGitHubRepository",

        # github-teams.ps1
        "Get-GitHubTeamId",
        
        #visual-studio.ps1
        "New-VisualStudioRepository")