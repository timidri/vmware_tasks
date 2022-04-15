#!/usr/bin/env pwsh
# Setup error handling
Set-StrictMode -Version 3.0
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'

$params = $input
$json = $params | ConvertFrom-Json -AsHashtable
# create a variable for each json key/value pair
foreach ($h in $json.GetEnumerator() ) {
  New-Variable -Name $h.Name -Value $h.Value
}

try {
  Write-Output "Adding a disk of size [$size] to vm [$vm_name] ..."
  # Connect to VCenter
  Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
  # Create the new disk
  Get-VM $vm_name | New-HardDisk -CapacityGB $size -StorageFormat Thin
}
catch {
  Write-Output "Error adding a disk:"
  Write-Output $PSItem
}