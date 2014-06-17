<#

.SYNOPSIS

Populates a repository with files useful for Visual Studio solutions.


.DESCRIPTION

The New-VisualStudioRepository copies files useful for Visual Studio solutions into a local directory.


.PARAMETER $RepositoryDirectory

The directory into which files are copied.


.PARAMETER $OverwriteDirectory

Determines if an existing directory is deleted before copying files.

If unspecified, an existing directory will not be deleted.


.EXAMPLE

Deletes an existing directory, then copies files into the foo-bar repository.

New-VisualStudioRepository C:\Git\foo-bar -OverwriteDirectory

#>
function New-VisualStudioRepository
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepositoryDirectory,
        [Switch]$OverwriteDirectory)

    $visualStudioRepositoryDirectory = Join-Path $PSScriptRoot visual-studio-repository

    if ($OverwriteDirectory -and (Test-Path $OverwriteDirectory))
    {
        Remove-Item (Join-Path $RepositoryDirectory *) -Recurse -Force -Exclude .git
    }

    Copy-Item (Join-Path $visualStudioRepositoryDirectory *) $RepositoryDirectory -Force -Recurse
}

function Get-VisualStudioSolutionProjectMatches
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath)

    Select-MatchesInContent `
        -Path $SolutionPath `
        -Pattern 'Project\("\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}"\) = "(?<ProjectName>.*?)", "(?<ProjectPath>.*?)", "\{(?<ProjectGuid>[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})\}"'
}

function Reset-VisualStudioSolutionProjectGuids
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Get-Item $SolutionPath).DirectoryName $match["ProjectPath"]
        $newProjectGuid = [guid]::NewGuid()

        Set-MatchReplacementsInContent $projectPath $match["ProjectGuid"] $newProjectGuid.ToString("D").ToUpper()
        Set-MatchReplacementsInContent $SolutionPath $match["ProjectGuid"] $newProjectGuid.ToString("D").ToUpper()
    }
}

function Set-VisualStudioSolutionProjectRootNamespaces
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Mandatory=$true)]
        [string]$RootNamespacePrefix)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Get-Item $SolutionPath).DirectoryName $match["ProjectPath"]

        Set-MatchReplacementsInContent $projectPath "<RootNamespace>(?<RootNamespace>.*)</RootNamespace>" "<RootNamespace>$RootNamespacePrefix.`${RootNamespace}</RootNamespace>"
    }
}

function Set-VisualStudioSolutionProjectAssemblyNames
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Mandatory=$true)]
        [string]$AssemblyNamePrefix)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Get-Item $SolutionPath).DirectoryName $match["ProjectPath"]

        Set-MatchReplacementsInContent $projectPath "<AssemblyName>(?<AssemblyName>.*)</AssemblyName>" "<AssemblyName>$AssemblyNamePrefix.`${AssemblyName}</AssemblyName>"
    }
}

function Set-VisualStudioSolutionProjectAssemblyInfoAttributes
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Mandatory=$true)]
        [string]$RootNamespacePrefix,
        [string]$Description,
        [string]$Company,
        [string]$Product,
        [string]$Copyright,
        [string]$Trademark,
        [string]$Culture)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Split-Path $SolutionPath -Parent) $match["ProjectPath"]
        $assemblyInfoPath = Join-Path (Split-Path $projectPath -Parent) Properties\AssemblyInfo.cs

        Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyTitle\("(?<AssemblyTitle>.*)"\)\]' "[assembly:AssemblyTitle(`"$RootNamespacePrefix.`${AssemblyTitle}`")]"
        if ($Description)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyDescription\(".*"\)\]' "[assembly:AssemblyDescription(`"$Description`")]"
        }
        if ($Company)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyCompany\(".*"\)\]' "[assembly:AssemblyCompany(`"$Company`")]"
        }
        if ($Product)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyProduct\(".*"\)\]' "[assembly:AssemblyProduct(`"$Product`")]"
        }
        if ($Copyright)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyCopyright\(".*"\)\]' "[assembly:AssemblyCopyright(`"$Copyright`")]"
        }
        if ($Trademark)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyTrademark\(".*"\)\]' "[assembly:AssemblyTrademark(`"$Trademark`")]"
        }
        if ($Culture)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:AssemblyCulture\(".*"\)\]' "[assembly:AssemblyCulture(`"$Culture`")]"
        }
    }
}

function Set-VisualStudioSolutionCodeNamespaces
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Mandatory=$true)]
        [string]$RootNamespacePrefix)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Split-Path $SolutionPath -Parent) $match["ProjectPath"]
        $projectDirectory = Split-Path $projectPath -Parent
        $codePaths = Get-ChildItem $projectDirectory -Recurse -Include *.cs -Exclude AssemblyInfo.cs

        foreach ($codePath in $codePaths)
        {
            Set-MatchReplacementsInContent $codePath "namespace (?<Namespace>.*)" "namespace $RootNamespacePrefix.`${Namespace}"
        }
    }
}

function Set-VisualStudioSolutionGlobalAsaxInheritsNamespaces
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Mandatory=$true)]
        [string]$RootNamespacePrefix)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Split-Path $SolutionPath -Parent) $match["ProjectPath"]
        $projectDirectory = Split-Path $projectPath -Parent
        $globalAsaxPaths = Get-ChildItem $projectDirectory -Recurse -Include Global.asax

        foreach ($globalAsaxPath in $globalAsaxPaths)
        {
            Set-MatchReplacementsInContent $globalAsaxPath 'Inherits="(?<Class>.*)"' "Inherits=`"$RootNamespacePrefix.`${Class}`""
        }
    }
}

function Set-VisualStudioSolutionProjectRandomIisUrlPort
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath)

    $matches = Get-VisualStudioSolutionProjectMatches $SolutionPath

    foreach ($match in $matches)
    {
        $projectPath = Join-Path (Split-Path $SolutionPath -Parent) $match["ProjectPath"]
        $port = Get-Random -Minimum 1024 -Maximum 49152

        Set-MatchReplacementsInContent $projectPath "<IISUrl>http://localhost:(?<Port>.*)</IISUrl>" "<IISUrl>http://localhost:$port</IISUrl>"
    }
}