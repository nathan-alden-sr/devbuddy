function Get-GitHubRepositories
{
    Invoke-RestMethod -Uri "$Global:GitHubApiUrl/repos" -Headers $Global:GitHubHeaders
}

function New-GitHubRepository
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [string]$Description,
        [string]$HomePage,
        [Switch]$Private = $true,
        [Switch]$HasIssues,
        [Switch]$HasWiki,
        [Switch]$HasDownloads,
        [int]$TeamId)

    $body = @{
        name = $Name
        description = $Description
        home_page = $HomePage
        private = $Private
        has_issues = $HasIssues
        has_wiki = $HasWiki
        has_downloads = $HasDownloads
        team_id = $TeamId
    } | ConvertTo-Json

    Invoke-RestMethod "$GitHubApiUrl/repos" -Method Post -Headers $Global:GitHubHeaders -ContentType "application/json" -Body $body
}

function New-LocalClonedGitHubRepository
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory,
        [Switch]$OverwriteDirectory)

    if ($OverwriteDirectory -and (Test-Path $RepositoryDirectory))
    {
        Remove-Item $RepositoryDirectory -Recurse -Force
    }

    $GitHubRepositoryName = [System.Net.WebUtility]::UrlEncode($GitHubRepositoryName)
    $repositoryUrl = "$Global:GitHubUsernamePasswordUrl/{0}.git" -f $GitHubRepositoryName

    Start-Process $Global:GitPath -ArgumentList clone,$repositoryUrl,$RepositoryDirectory -Wait -WindowStyle Hidden

    Set-GetHubOriginRemote -GitHubRepositoryName $GitHubRepositoryName -RepositoryDirectory $RepositoryDirectory
}

function New-LocalGitHubRepository
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory,
        [Switch]$OverwriteDirectory)

    if ($OverwriteDirectory -and (Test-Path $RepositoryDirectory))
    {
        Remove-Item $RepositoryDirectory -Recurse -Force -ErrorAction Stop
    }

    Start-Process $Global:GitPath -ArgumentList init,--quiet,$RepositoryDirectory -Wait -WindowStyle Hidden

    Set-GetHubOriginRemote -GitHubRepositoryName $GitHubRepositoryName -RepositoryDirectory $RepositoryDirectory
}

function Set-GetHubOriginRemote
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory)

    Start-Process $Global:GitPath -WorkingDirectory $RepositoryDirectory -ArgumentList remote,remove,origin -Wait -WindowStyle Hidden
    Start-Process $Global:GitPath -WorkingDirectory $RepositoryDirectory -ArgumentList remote,add,origin,$Global:GitHubUsernameUrl -Wait -WindowStyle Hidden
}