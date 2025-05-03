# Привязка EIP к VIP портам (Associate)
resource "huaweicloud_vpc_eip_associate" "eip_associate_appgateway" {
  port_id   = huaweicloud_lb_loadbalancer.elb_appgateway.vip_port_id  # VIP порт Appgateway
  public_ip = huaweicloud_vpc_eip.eip[7].address                      # Адрес EIP
}

resource "huaweicloud_vpc_eip_associate" "eip_associate_fleetmanager" {
  port_id   = huaweicloud_lb_loadbalancer.elb_fleetmanager.vip_port_id
  public_ip = huaweicloud_vpc_eip.eip[8].address
}