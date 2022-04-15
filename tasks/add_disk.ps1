#!/usr/bin/env pwsh
$params = $input
$json = $params | ConvertFrom-Json -AsHashtable
# create a variable for each json key/value pair
foreach ($h in $json.GetEnumerator() ) {
  New-Variable -Name $h.Name -Value $h.Value
}

write-host "Adding a disk of size $size to vm $vm_name ..."

try {
  # Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
  New-Harddisk -VM $vm_name -CapacityGB $size
}
catch {
  Write-Output "Error adding a disk:"
  Write-Output $_
}