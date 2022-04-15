#!/usr/bin/env pwsh
$params = $input
$json = $params | ConvertFrom-Json -AsHashtable
# create a variable for each json key/value pair
foreach ($h in $json.GetEnumerator() ) {
    # write-host "$($h.Name) : $($h.Value)"
    New-Variable -Name $h.Name -Value $h.Value
}

try {
    # connect to VCenter
    Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
    # get list of VMs
    Get-VM -Name $vm_name | format-table
}
catch {
    Write-Output "Error listing VMs:"
    Write-Output $_
  }