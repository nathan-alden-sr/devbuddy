[string]$GitHubUrl = $null
[string]$GitHubUsernameUrl = $null
[string]$GitHubUsernamePasswordUrl = $null
[string]$GitHubApiUrl = $null
[System.Collections.IDictionary]$GitHubHeaders = $null

function Initialize-GitHub
{
    <#

    .SYNOPSIS

    Initializes GitHub support in the current session.


    .DESCRIPTION

    The Initialize-GitHub function initializes several parameters that are necessary to access the GitHub API.
    Parameters consist of various GitHub URLs and headers necessar for authorization.
    The variables are stored in the current session.

    If a clear-text password is not provided, the user will be prompted to enter one.
    Authentication will not be performed when calling Initialize-GitHub; authorization is only performed when calling subsequent GitHub-specific functions.


    .PARAMETER $Username

    A GitHub username.


    .PARAMETER $ClearTextPassword

    A clear-text password.

    If unspecified, the user will be prompted to enter their password.


    .PARAMETER $Organization

    The name of a GitHub organization.

    If unspecified, no organization will be used for subsequent API calls.


    .EXAMPLE

    Initializes GitHub support for a user named foo-bar. The user is prompted to enter their password.

    Initialize-GitHub foo-bar


    .EXAMPLE

    Initializes GitHub support for a user named foo-bar. The user is not prompted to enter their password.

    Initialize-GitHub foo-bar mypass123


    .EXAMPLE

    Initializes GitHub support for an organization named example-org. The user is prompted to enter their password.

    Initialize-GitHub foo-bar -Organization example-org


    .NOTES

    If GitHub is initialized without an organization then all API calls will associate with the provided username; otherwise, all API calls will associate with the provided organization.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [string]$ClearTextPassword,
        [string]$Organization)

    $Global:GitHubUrl = $null
    $Global:GitHubUsername = $null
    $Global:GitHubPassword = $null
    $Global:GitHubApiUrl = $null
    $Global:GitHubHeaders = $null

    if (!$Username)
    {
        $Username = Read-Host "GitHub username"
    }
    if (!$ClearTextPassword)
    {
        $ClearTextPassword = Convert-SecureStringToString(Read-Host "GitHub password for $Username" -AsSecureString)
    }

    $headerValue = [System.Text.Encoding]::UTF8.GetBytes("$Username`:$ClearTextPassword")
    $Global:GitHubHeaders = @{ 
        Authorization = "Basic " + [System.Convert]::ToBase64String($headerValue)
    }

    $Username = [System.Net.WebUtility]::UrlEncode($Username)
    $ClearTextPassword = [System.Net.WebUtility]::UrlEncode($ClearTextPassword)
    if ($Organization)
    {
        $Organization = [System.Net.WebUtility]::UrlEncode($Organization)
        $Global:GitHubUrl = "https://github.com/$Organization"
        $Global:GitHubUsernameUrl = "https://$Username@github.com/$Organization"
        $Global:GitHubUsernamePasswordUrl = "https://$Username`:$ClearTextPassword@github.com/$Organization"
        $Global:GitHubApiUrl = "https://api.github.com/orgs/$Organization"
    }
    else
    {
        $Global:GitHubUrl = "https://github.com/$Username"
        $Global:GitHubUsernameUrl = "https://$Username@github.com/$Username"
        $Global:GitHubUsernamePasswordUrl = "https://$Username`:$ClearTextPassword@github.com/$Username"
        $Global:GitHubApiUrl = "https://api.github.com/users/$Username"
    }
}