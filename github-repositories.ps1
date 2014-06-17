function Get-GitHubRepositories
{
    <#

    .SYNOPSIS

    Gets all GitHub repositories for the user or organization in the current session.


    .DESCRIPTION

    The Get-GitHubRepository function gets all GitHub repositories for the user or organization in the current session.


    .EXAMPLE

    Get-GitHubRepositories

    #>
    Invoke-RestMethod -Uri "$Global:GitHubApiUrl/repos" -Headers $Global:GitHubHeaders
}

function New-GitHubRepository
{
    <#

    .SYNOPSIS

    Creates a new repository in GitHub.


    .DESCRIPTION

    The New-GitHubRepository creates a repository directly in GitHub. No local repository is created or cloned.


    .PARAMETER $Name

    The name of the new repository.


    .PARAMETER $Description

    A description for the new repository.

    If unspecified, no description will be used.


    .PARAMETER $HomePage

    The home page of the new repository.

    If unspecified, no home page will be used.


    .PARAMETER $Private

    Determines if the new repository is private.

    If unspecified, the repository will be private.


    .PARAMETER $HasIssues

    Determines if the new repository has an issues page.

    If unspecified, the repository will not have an issues page.


    .PARAMETER $HasWiki

    Determines if the new repository has a wiki.

    If unspecified, the repository will not have a wiki.


    .PARAMETER $HasDownloads

    Determines if the new repository has a downloads page.

    If unspecified, the repository will not have a downloads page.


    .PARAMETER $TeamId

    The team ID associated with the new repository. This parameter is only required when GitHub was initialized with an organization.

    If unspecified, the repository will not be associated with a team.


    .EXAMPLE

    Creates a new user GitHub repository named foo-bar with a home page, an issues page, and a wiki.

    New-GitHubRepository foo-bar -HomePage http://example.org/foo-bar -HasIssues -HasWiki


    .EXAMPLE

    Creates a new organization GitHub repository named foo-bar with a home page, description, and a downloads page.

    New-GitHubRepository foo-bar "Foo-Bar repo" http://example.org/foo-bar -HasDownloads -TeamId 123

    #>
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
    <#

    .SYNOPSIS

    Clones a GitHub repository to a local directory.


    .DESCRIPTION

    The New-LocalClonedGitHubRepository function clones a GitHub repository to a local directory.


    .PARAMETER $GitHubRepositoryName

    The name of the repository in GitHub.


    .PARAMETER $RepositoryDirectory

    The directory into which the GitHub repository is cloned.


    .PARAMETER $OverwriteDirectory

    Determines if an existing repository directory is deleted before cloning.

    If unspecified, an existing directory will not be deleted.


    .EXAMPLE

    Clones a GitHub repository named foo-bar and overwrites the existing directory.

    New-LocalClonedGitHubRepository foo-bar C:\Git\foo-bar -OverwriteDirectory

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory,
        [Switch]$OverwriteDirectory)

    if ($OverwriteDirectory -and (Test-Path $RepositoryDirectory))
    {
        [System.IO.Directory]::Delete($RepositoryDirectory, $true)
    }

    $GitHubRepositoryName = [System.Net.WebUtility]::UrlEncode($GitHubRepositoryName)
    $repositoryUrl = "$Global:GitHubUsernamePasswordUrl/{0}.git" -f $GitHubRepositoryName

    Start-Process $Global:GitPath -ArgumentList clone,`"$repositoryUrl`",`"$RepositoryDirectory`" -Wait -WindowStyle Hidden

    Set-GitHubOriginRemote -GitHubRepositoryName $GitHubRepositoryName -RepositoryDirectory $RepositoryDirectory
}

function New-LocalGitHubRepository
{
    <#

    .SYNOPSIS

    Creates a new repository in a local directory and configures sets origin remote for GitHub.


    .DESCRIPTION

    The New-LocalGitHubRepository function creates a new repository in a local directory and configures sets origin remote for GitHub.
    The repository is only initialized, not cloned.


    .PARAMETER $GitHubRepositoryName

    The name of the repository in GitHub. A repository with this name does not need to exist.


    .PARAMETER $RepositoryDirectory

    The directory where the repository is created.


    .PARAMETER $OverwriteDirectory

    Determines if an existing repository directory is deleted before creating the repository.

    If unspecified, an existing directory will not be deleted.


    .EXAMPLE

    Creates a local repository named foo-bar.

    New-LocalGitHubRepository foo-bar C:\Git\foo-bar

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory,
        [Switch]$OverwriteDirectory)

    if ($OverwriteDirectory -and (Test-Path $RepositoryDirectory))
    {
        [System.IO.Directory]::Delete($RepositoryDirectory, $true)
    }

    Start-Process $Global:GitPath -ArgumentList init,--quiet,`"$RepositoryDirectory`" -Wait -WindowStyle Hidden

    Set-GitHubOriginRemote -GitHubRepositoryName $GitHubRepositoryName -RepositoryDirectory $RepositoryDirectory
}

function Set-GitHubOriginRemote
{
    <#

    .SYNOPSIS

    Sets a local repository's origin remote to a GitHub repository URL.


    .DESCRIPTION

    The Set-GitHubOriginRemote function removes any remotes named origin, then creates a new origin remote with the appropriate GitHub repository URL.


    .PARAMETER $GitHubRepositoryName

    The name of the repository in GitHub. A repository with this name does not need to exist.


    .PARAMETER $RepositoryDirectory

    The directory where the repository is created.


    .EXAMPLE

    Sets the origin remote to a GitHub repository URL that points to a foo-bar repository.

    Set-GitHubOriginRemote foo-bar C:\Git\foo-bar

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GitHubRepositoryName,
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory)

    Start-Process $Global:GitPath -WorkingDirectory $RepositoryDirectory -ArgumentList remote,remove,origin -Wait -WindowStyle Hidden
    Start-Process $Global:GitPath -WorkingDirectory $RepositoryDirectory -ArgumentList remote,add,origin,"$Global:GitHubUsernameUrl/$GitHubRepositoryName" -Wait -WindowStyle Hidden
}