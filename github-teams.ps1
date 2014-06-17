function Get-GitHubTeamId
{
    <#

    .SYNOPSIS

    Gets a GitHub team ID by name.


    .DESCRIPTION

    The Get-GitHubTeamId function gets a GitHub team ID by name.


    .PARAMETER $TeamName

    A GitHub team name.


    .EXAMPLE

    Gets the ID of a GitHub team named foo-bar-team.

    Get-GitHubTeamId foo-bar-team

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TeamName
    )

    $teams = Invoke-RestMethod "$GitHubApiUrl/teams" -Headers $Global:GitHubHeaders

    return $teams | ?{ $_.name -eq $TeamName} | %{ $_.id }
}