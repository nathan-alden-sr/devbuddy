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

<#

.SYNOPSIS

Gets projects referenced by a Visual Studio solution.


.DESCRIPTION

The Get-VisualStudioSolutionProjectMatches function gets projects referenced by a Visual Studio solution.
Projects are returned as regular expression matches.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.EXAMPLE

Gets all projects in a foo-bar.sln solution.

Get-VisualStudioSolutionProjectMatches C:\Git\foo-bar\foo-bar.sln

#>
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

<#

.SYNOPSIS

Replaces all project GUIDs in a Visual Studio solution with new GUIDs and updates the referenced projects accordingly.


.DESCRIPTION

The Reset-VisualStudioSolutionProjectGuids function replaces all project GUIDs in a solution with new GUIDs.
Then, replaces the corresponding GUIDs in each referenced project file with the new GUID for that project.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.EXAMPLE

Resets all project GUIDs in a foo-bar.sln solution.

Reset-VisualStudioSolutionProjectGuids C:\Git\foo-bar\foo-bar.sln


.NOTES

Use this function to prevent project GUIDs in a template from existing in multiple solutions.

#>
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

<#

.SYNOPSIS

Prepends a prefix to the root namespace in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionProjectRootNamespaces function prepends a prefix to the root namespace in all projects referenced by a Visual Studio solution.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.PARAMETER $RootNamespacePrefix

A prefix to prepend to all root namespaces.


.EXAMPLE

Prepends Foo.Bar to all projects' root namespaces in a foo-bar.sln solution.

Set-VisualStudioSolutionProjectRootNamespaces C:\Git\foo-bar\foo-bar.sln Foo.Bar


.NOTES

For example, if a project in a solution has a root namespace of Baz and a prefix of Foo.Bar is prepended, the new root namespace will be Foo.Bar.Baz.

#>
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

<#

.SYNOPSIS

Prepends a prefix to the assembly name in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionProjectAssemblyNames function prepends a prefix to the assembly name in all projects referenced by a Visual Studio solution.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.PARAMETER $AssemblyNamePrefix

A prefix to prepend to all assembly names.


.EXAMPLE

Prepends Foo.Bar to all projects' assembly names in a foo-bar.sln solution.

Set-VisualStudioSolutionProjectAssemblyNames C:\Git\foo-bar\foo-bar.sln Foo.Bar


.NOTES

For example, if a project in a solution has an assembly name of Baz and a prefix of Foo.Bar is prepended, the new assembly name will be Foo.Bar.Baz.

#>
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

<#

.SYNOPSIS

Sets the values of several AssemblyInfo.cs attributes in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionProjectAssemblyInfoAttributes function sets the values of several AssemblyInfo.cs attributes in all projects referenced by a Visual Studio solution.
The function assumes a relative path of Properties\AssemblyInfo.cs for locating each referenced project's AssemblyInfo.cs file.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.PARAMETER $RootNamespacePrefix

A prefix to prepend to the AssemblyTitle attribute's value.


.PARAMETER $Description

A value for the AssemblyDescription attribute.

If unspecified, the value is left unchanged.


.PARAMETER $Company

A value for the AssemblyCompany attribute.

If unspecified, the value is left unchanged.


.PARAMETER $Product

A value for the AssemblyProduct attribute.

If unspecified, the value is left unchanged.


.PARAMETER $Copyright

A value for the AssemblyCopyright attribute.

If unspecified, the value is left unchanged.


.PARAMETER $Trademark

A value for the AssemblyTrademark attribute.

If unspecified, the value is left unchanged.


.PARAMETER $Culture

A value for the AssemblyCulture attribute.

If unspecified, the value is left unchanged.


.EXAMPLE

Sets various assembly attributes values in a foo-bar.sln solution.

Set-VisualStudioSolutionProjectAssemblyInfoAttributes `
    foo-bar.sln `
    Foo.Bar `
    "Foo Bar" `
    "Baz Inc." `
    "Foo Bar" `
    "Copyright Baz Inc." `
    "Foo Bar" `
    "en"

#>
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

        Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyTitle\("(?<AssemblyTitle>.*)"\)\]' "[assembly:AssemblyTitle(`"$RootNamespacePrefix.`${AssemblyTitle}`")]"
        if ($Description)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyDescription\(".*"\)\]' "[assembly:AssemblyDescription(`"$Description`")]"
        }
        if ($Company)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyCompany\(".*"\)\]' "[assembly:AssemblyCompany(`"$Company`")]"
        }
        if ($Product)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyProduct\(".*"\)\]' "[assembly:AssemblyProduct(`"$Product`")]"
        }
        if ($Copyright)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyCopyright\(".*"\)\]' "[assembly:AssemblyCopyright(`"$Copyright`")]"
        }
        if ($Trademark)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyTrademark\(".*"\)\]' "[assembly:AssemblyTrademark(`"$Trademark`")]"
        }
        if ($Culture)
        {
            Set-MatchReplacementsInContent $assemblyInfoPath '\[assembly:\s*AssemblyCulture\(".*"\)\]' "[assembly:AssemblyCulture(`"$Culture`")]"
        }
    }
}

<#

.SYNOPSIS

Prefixes all namespaces in all .cs code files in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionCodeNamespaces function prefixes all namespaces in all .cs code files in all projects referenced by a Visual Studio solution.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.PARAMETER $RootNamespacePrefix

A prefix to prepend to all namespaces in all .cs code files.


.EXAMPLE

Prepends a prefix of Foo.Bar to all namespaces in all .cs code files in all projects in a foo-bar.sln solution.

Set-VisualStudioSolutionCodeNamespaces C:\Git\foo-bar.sln Foo.Bar

#>
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

<#

.SYNOPSIS

Prefixes all namespaces in all Global.asax files in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionGlobalAsaxInheritsNamespaces function prefixes all namespaces in all Global.asax files in all projects referenced by a Visual Studio solution.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.PARAMETER $RootNamespacePrefix

A prefix to prepend to all namespaces in all Global.asax files.


.EXAMPLE

Prepends a prefix of Foo.Bar to all namespaces in all Global.asax files in all projects in a foo-bar.sln solution.

Set-VisualStudioSolutionGlobalAsaxInheritsNamespaces C:\Git\foo-bar.sln Foo.Bar

#>
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

<#

.SYNOPSIS

Sets random IIS ports in all projects referenced by a Visual Studio solution.


.DESCRIPTION

The Set-VisualStudioSolutionProjectRandomIisUrlPort function sets random IIS ports in all projects referenced by a Visual Studio solution.


.PARAMETER $SolutionPath

A path to a Visual Studio solution file.


.EXAMPLE

Sets random IIS ports in all projects referenced by a foo-bar.sln solution.

Set-VisualStudioSolutionProjectRandomIisUrlPort C:\Git\foo-bar.sln


.NOTES

Use this function to prevent IIS ports in a template from existing in multiple solutions.
A port between 1024 to 49151 (inclusive) is randomly generated for each project.

#>
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