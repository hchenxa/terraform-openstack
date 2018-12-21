resource "openstack_networking_port_v2" "port" {
  name           = "port-${count.index}"
  network_id     = "e2d9ead6-759b-4592-873d-981d3db07c86"
  count = 3
  admin_state_up = "true"
  allowed_address_pairs = {
    ip_address = "${local.ip_addresses}"
  }
  depends_on = ["openstack_networking_port_v2.vip"]
}

locals {
  ip_addresses = "${element(flatten(openstack_networking_port_v2.vip.*.all_fixed_ips), 0)}"
}

resource "openstack_networking_port_v2" "vip" {
  name           = "vip"
  network_id     = "e2d9ead6-759b-4592-873d-981d3db07c86"
  admin_state_up = "true"
}

resource "openstack_compute_instance_v2" "icp-master" {
   count = 3
   name             = "hchenter-${count.index}"
   image_name        = "KVM-Ubt18.04-Srv-x64"
   key_pair          = "hchenxa"
   flavor_name       = "m1.medium"
   availability_zone = "nova"

   network {
     port = "${element(openstack_networking_port_v2.port.*.id, count.index)}"
   }
}
