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
