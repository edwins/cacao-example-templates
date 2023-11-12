terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack" # "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

provider "openstack" {
  tenant_name = var.project
  region = var.region
}

resource "openstack_compute_instance_v2" "os_instances" {
  name = var.instance_name
  image_id = var.image
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = ["cacao-default"]
  power_state = var.power_state
  user_data = var.user_data

  network {
    name = "auto_allocated_network"
  }
}

data "openstack_networking_network_v2" "ext_network" {
  # make the assumption that there is only 1 external network per region, this will fail if otherwise
  region = var.region
  external = true
}

resource "openstack_networking_floatingip_v2" "os_floatingips" {
  count = var.power_state == "active" ? 1 : 0
  pool = data.openstack_networking_network_v2.ext_network.name
  description = "floating ip for ${var.instance_name}"
}

resource "openstack_compute_floatingip_associate_v2" "os_floatingips_associate" {
  count = var.power_state == "active" ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.os_floatingips[0].address
  instance_id = openstack_compute_instance_v2.os_instances.id
}