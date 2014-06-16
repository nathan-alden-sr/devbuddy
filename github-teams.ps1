function Get-GitHubTeamId
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$TeamName
    )

    $teams = Invoke-RestMethod "$GitHubApiUrl/teams" -Headers $Global:GitHubHeaders

    return $teams | ?{ $_.name -eq $TeamName} | %{ $_.id }
}