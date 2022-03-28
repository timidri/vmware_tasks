#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    # username
    [Parameter(Mandatory=$True)]
    [String]$Username,

    # password
    [Parameter(Mandatory=$True)]
    [String]$Password
)

write-host hello
Connect-VIServer -Server vcenter-ci1.ops.puppetlabs.net -Protocol https -User $Username -Password $Password
#Connect-VIServer -Server vcenter-ci1.ops.puppetlabs.net -Protocol https -Credential $credential
Get-VM | format-table
