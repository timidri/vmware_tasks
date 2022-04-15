#!/usr/bin/env pwsh
$params = $input
$json = $params | ConvertFrom-Json -AsHashtable
# create a variable for each json key/value pair
foreach ($h in $json.GetEnumerator() ) {
    New-Variable -Name $h.Name -Value $h.Value
}

Connect-VIServer -Server $server -Protocol https -User $username -Password $password | Out-Null
# print error, if any
if ($Error -ne $null) {
    Write-Host $Error
    Exit 1
}

# set disk.EnableUUID to true, create the setting if it doesn't exist
New-AdvancedSetting -Entity $vm_name -Name disk.EnableUUID -Value TRUE -Confirm:$False -Force:$True