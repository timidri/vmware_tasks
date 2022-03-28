#!/usr/bin/env pwsh
$params = $input
write-host $params.ToString()
$json = $params | ConvertFrom-Json -AsHashtable
write-host $json
foreach ($h in $json.GetEnumerator() ) {
    write-host "$($h.Name) : $($h.Value)"
    New-Variable -Name $h.Name -Value $h.Value
}
write-host server: $server
write-host username: $username
Connect-VIServer -Server $server -Protocol https -User $username -Password $password
Get-VM | format-table | Write-Output
write-host "hello"