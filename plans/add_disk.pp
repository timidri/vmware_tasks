plan vmware_tasks::add_disk (
  String[1] $vm_name,
  String[1] $size,
  TargetSpec $target,
  TargetSpec $vmware_jumphost='primary.relay.vm',
  Optional[Float[0,1]] $avail_percentage = 0.99,
) {

  run_task('vmware_tasks::add_disk', vm_name => $vn_name, size => $size)

  fail_plan('end')

  $target_facts = run_plan('facts', $target).first()
  $target_disks = $target_facts.value['disks']
  out::message($target_disks)

  $uuid = String('6000c29b437a89c547a4f7cad9ca61d2')
  # $disk = $target_disks.each | $name, $props | {
  $found = $target_disks.filter | $disk | {
    out::message($disk)
    $disk[1]['serial'] == $uuid
  }
  out::message("found: ${found}, keys: ${found.keys()}")
  if $found.length() != 1 {
    fail_plan("Could not find disk wuth uuid ${uuid}, exiting")
  }
  $disk = $found.keys()[0]
  out::message("found disk: ${disk}")

  $disk_size = $found[$disk]['size_bytes']
  out::message("disk size: ${disk_size}")

  $requested_size = lvm::size_to_bytes($size)
  out::message("requested_size: ${requested_size}")

  $available_size = $disk_size * $avail_percentage
  out::verbose("available_size: ${available_size}")


  run_plan('lvm::expand', )
}
