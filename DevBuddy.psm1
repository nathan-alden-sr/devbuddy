#requires -version 3

Set-StrictMode -Version latest

if (Get-Module DevBuddy)
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
        # common.ps1
        "Convert-SecureStringToString",
        "Get-ProgramFilesX86Directory",
        "Select-MatchesInContent",
        "Set-MatchReplacementsInContent"

        # git.ps1
        "Initialize-Git",

        # github.ps1
        "Initialize-GitHub",

        # github-repositories.ps1
        "Get-GitHubRepositories",
        "New-GitHubRepository",
        "New-LocalGitHubRepository",
        "New-LocalClonedGitHubRepository",
        "Set-GitHubOriginRemote",

        # github-teams.ps1
        "Get-GitHubTeamId",
        
        #visual-studio.ps1
        "New-VisualStudioRepository",
        "Get-VisualStudioSolutionProjectMatches",
        "Reset-VisualStudioSolutionProjectGuids",
        "Set-VisualStudioSolutionProjectRootNamespaces",
        "Set-VisualStudioSolutionProjectAssemblyNames",
        "Set-VisualStudioSolutionProjectAssemblyInfoAttributes",
        "Set-VisualStudioSolutionCodeNamespaces",
        "Set-VisualStudioSolutionGlobalAsaxInheritsNamespaces",
        "Set-VisualStudioSolutionProjectRandomIisUrlPort") `
    -Variable @(
        #git.ps1
        "GitPath",

        #github.ps1
        "GitHubUrl",
        "GitHubUsernameUrl",
        "GitHubUsernamePasswordUrl",
        "GitHubApiUrl",
        "GitHubHeaders")