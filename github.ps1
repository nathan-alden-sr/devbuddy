[string]$GitHubUrl = $null
[string]$GitHubUsernameUrl = $null
[string]$GitHubUsernamePasswordUrl = $null
[string]$GitHubApiUrl = $null
[System.Collections.IDictionary]$GitHubHeaders = $null

function Initialize-GitHub
{
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