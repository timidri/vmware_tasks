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
  # Get VM information, convert to json. Include IpAddress and HostName guest properties
  $json = Get-Vm -Name $vm_name |
  Select-Object PowerState, Name, NumCpu, MemoryMB, @{N = "IpAddress"; E = { @($_.guest.IPAddress[0]) } }, @{N = "HostName"; E = { @($_.guest.hostname) } }  | 
  convertto-json -depth 10
  # Convert json keys to snake_case
  $json_snake_case = [regex]::Replace( $json, '(?<=")(\w+)(?=":)', { ConvertTo-SnakeCase($args[0].Groups[1].Value) } )
  Write-Output $json_snake_case
}
catch {
  Write-Output "Error getting VM information:"
  Write-Output $PSItem
  Exit 1
}