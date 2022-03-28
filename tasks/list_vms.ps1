#!/usr/bin/env pwsh
$params = $input
$json = $params | ConvertFrom-Json -AsHashtable
# create a variable for each json key/value pair
foreach ($h in $json.GetEnumerator() ) {
    # write-host "$($h.Name) : $($h.Value)"
    New-Variable -Name $h.Name -Value $h.Value
}

Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
# print error, if any
if ($Error -ne $null) {
    Write-Host $Error
    Exit 1
}

# get list of VMs
Get-VM -Name $vm_name | format-table