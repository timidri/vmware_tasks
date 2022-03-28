# !/usr/bin/env pwsh
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)] [String] $username,
    [Parameter(Mandatory = $True)] [SecureString] $password
)

write-host hello
Connect-VIServer -Server vcenter-ci1.ops.puppetlabs.net -Protocol https -User $username -Password $password
#Connect-VIServer -Server vcenter-ci1.ops.puppetlabs.net -Protocol https -Credential $credential
Get-VM | format-table
