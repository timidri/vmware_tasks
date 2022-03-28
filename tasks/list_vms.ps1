#!/usr/bin/env pwsh
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)] [String] $server,
    [Parameter(Mandatory = $True)] [String] $username,
    [Parameter(Mandatory = $True)] [String] $password
)

write-host hello
Connect-VIServer -Server $server -Protocol https -User $username -Password $password
Get-VM | format-table
