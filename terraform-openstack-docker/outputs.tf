output "instance_uuids" {
  value = tolist(openstack_compute_instance_v2.os_instances.*.id)
}
output "instance_ips" {
  value = tolist(openstack_networking_floatingip_v2.os_floatingips.*.address)
}