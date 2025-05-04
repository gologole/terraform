# Привязка EIP к VIP порту AppGateway
resource "sbercloud_networking_eip_associate" "eip_associate_appgateway" {
  port_id   = sbercloud_lb_loadbalancer.elb_appgateway.vip_port_id  # VIP порт AppGateway
  public_ip = sbercloud_vpc_eip.eip[7].address                      # Адрес EIP
}

# Привязка EIP к VIP порту FleetManager
resource "sbercloud_networking_eip_associate" "eip_associate_fleetmanager" {
  port_id   = sbercloud_lb_loadbalancer.elb_fleetmanager.vip_port_id  # VIP порт FleetManager
  public_ip = sbercloud_vpc_eip.eip[8].address                        # Адрес EIP
}

# Выделенные публичные IP для VPC
resource "sbercloud_vpc_eip" "eip" {
  count = 9
  name  = "${var.vpc_name}-eip-${count.index + 1}"

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${var.vpc_name}-bandwidth-${count.index + 1}"
    share_type  = "PER"
    size        = var.eip_bandwidth_size
    charge_mode = "bandwidth"
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}