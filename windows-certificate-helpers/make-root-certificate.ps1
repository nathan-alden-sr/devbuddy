$defaultRootAuthorityCN = "$env:COMPUTERNAME Root Authority"
$rootAuthorityCN = Read-Host "Root authority CN (defaults to $defaultRootAuthorityCN)"
if ($rootAuthorityCN.Length -eq 0)
{
    $rootAuthorityCN = $defaultRootAuthorityCN
}
$outputPath = "$rootAuthorityCN.cer"
& .\makecert.exe -pe -n "CN=$rootAuthorityCN" -ss Root -sr LocalMachine -a sha512 -sky signature -r $outputPath
"Saved certificate to $outputPath"