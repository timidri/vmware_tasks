plan vmware_tasks::add_disk (
  String[1] $vcenter_host,
  String[1] $username,
  Sensitive $password,
  String[1] $vm_name,
  Pattern[/^[0-9]+$/,/^[0-9]+\.[0-9]+$/,/full/] $size_gb, # allow decimal point format or the string "full"
  String[1] $logical_volume = 'root',
  String[1] $volume_group = 'cl',
  Enum['yes','no'] $resize_fs = 'yes',
  TargetSpec $target,
) {

  $vcenter_params = { server => $vcenter_host, username => $username, password => $password.unwrap(), }

  # get the VM information
  $vm_info = run_task('vmware_tasks::get_vm', $target, $vcenter_params + { vm_name => $vm_name }).first().value
  if empty($vm_info) {
    fail_plan("Unable to get vm info for ${vm_name}")
  }
  out::verbose($vm_info)
  $hostname = $vm_info['host_name']
  if empty($hostname) {
    fail_plan("Unable to get hostname for ${vm_name}. The hostname should be set and equal to the certname in PE.")
  }

  # get VM's current disk layout
  out::message(run_command('df -h', $hostname))

  # add a new disk with required capacity
  $hard_disk = run_task('vmware_tasks::add_disk', $target, $vcenter_params + { vm_name => $vm_name, size => $size_gb }).first().value
  if empty($hard_disk) {
    fail_plan("Unable to add disk to vm ${vm_name} of size ${size_gb}GB")
  }
  out::verbose($hard_disk)
  $hd_name = $hard_disk['name']

  # lowercase the UUID and remove dashes to become Linux-compatible
  $uuid = regsubst($hard_disk['uuid'], '-', '', 'G').downcase()
  out::verbose($uuid)

  # Get disk facts on the VM
  # Assumption here is that the hostname is the same as the certname
  $target_facts = run_plan('facts', $hostname).first().value
  $target_disks = $target_facts['disks']
  out::verbose($target_disks)

  # search for the disk with our UUID, that parameter is called `serial` in the fact
  $found = $target_disks.filter | $disk | {
    $disk[1]['serial'] == $uuid
  }
  if $found.length() != 1 {
    fail_plan("Could not find disk wuth uuid ${uuid}, exiting")
  }
  $disk = $found.keys()[0]
  $disk_size = $found[$disk]['size_bytes']
  out::message("found disk: ${disk}, size: ${disk_size}")

  # use lvm to add the disk and optionally resize the filesystem
  out::message("Adding disk to ${hostname}...")

  $additional_size = $size_gb ? {
    'full'  => undef,
    default => "${size_gb}GB",
  }
  run_plan('lvm::expand',
  {
    additional_size => undef,
    disks => ["/dev/${disk}"],
    logical_volume => $logical_volume,
    resize_fs => $resize_fs == 'yes',
    server => $hostname,
    volume_group => $volume_group,
  })

  # get VM's current disk layout
  out::message(run_command('df -h', $hostname))

  out::message("Adding disk ${disk} of size ${size_gb}GB to ${vm_name} (${hostname}) successful!")
}
