# $in = Read-Host
# write-host in: $input
$json = $input | ConvertFrom-Json -AsHashtable
# write-host $json
foreach ($h in $json.GetEnumerator() ) {
  write-host "$($h.Name) : $($h.Value)"
  Set-Variable $h.Name $h.Value
}
write-host $a