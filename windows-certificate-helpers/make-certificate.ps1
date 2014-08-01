$defaultRootAuthorityCN = "$env:COMPUTERNAME Root Authority"
$rootAuthorityCN = Read-Host "Root authority CN (defaults to $defaultRootAuthorityCN)"
if ($rootAuthorityCN.Length -eq 0)
{
    $rootAuthorityCN = $defaultRootAuthorityCN
}
$personalCN = Read-Host "Personal CN"
$outputPath = "$personalCN.cer"
& .\makecert.exe -pe -n "CN=$personalCN" -ss My -sr LocalMachine -a sha512 -sky exchange -eku 1.3.6.1.5.5.7.3.1 -in $rootAuthorityCN -is Root -ir LocalMachine -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12 $outputPath
"Saved certificate to $outputPath"