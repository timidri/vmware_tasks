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

# Function to convert from CamelCase to snake_case
function ConvertTo-SnakeCase {
  [OutputType('System.String')]
  param(
    [Parameter(Position = 0)]
    [string] $Value
  )

  return [regex]::replace($Value, '(?<=[a-z])(?=[A-Z])', '_').ToLower()
}

try {
  # Connect to VCenter
  Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
  # Create the new disk
  $vm = Get-VM $vm_name
  $harddisk = New-HardDisk -VM $vm -CapacityGB $size -StorageFormat Thin
  # Convert output to json
  $json = $harddisk | Select-Object name, capacitygb, @{N = 'vm_name'; E = { $_.parent.name } }, @{N = 'UUID'; E = { $_.ExtensionData.Backing.Uuid } } | ConvertTo-Json
  # Convert json keys to snake_case
  $json_snake_case = [regex]::Replace( $json, '(?<=")(\w+)(?=":)', { ConvertTo-SnakeCase($args[0].Groups[1].Value) } )
  Write-Output $json_snake_case
}
catch {
  Write-Output "Error adding a disk:"
  Write-Output $PSItem
  Exit 1
}