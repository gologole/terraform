# Балансировщики нагрузки (ELB)
resource "sbercloud_lb_loadbalancer" "elb_appgateway" {
  name          = "${var.elb_name}_appgateway"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

resource "sbercloud_lb_loadbalancer" "elb_aass" {
  name          = "${var.elb_name}_aass"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

resource "sbercloud_lb_loadbalancer" "elb_fleetmanager" {
  name          = "${var.elb_name}_fleetmanager"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

# Слушатели ELB (Listener)
resource "sbercloud_lb_listener" "elb_listener_appgateway" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_appgateway.id
  protocol        = "TCP"
  protocol_port   = 60003
}

resource "sbercloud_lb_listener" "elb_listener_aass" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_aass.id
  protocol        = "TCP"
  protocol_port   = 9091
}

resource "sbercloud_lb_listener" "elb_listener_fleetmanager" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_fleetmanager.id
  protocol        = "TCP"
  protocol_port   = 31002
}

# Пулы бекенд‑серверов (Pool)
resource "sbercloud_lb_pool" "elb_pool_appgateway" {
  name        = "elb_pool_appgateway"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_appgateway.id
}

resource "sbercloud_lb_pool" "elb_pool_aass" {
  name        = "elb_pool_aass"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_aass.id
}

resource "sbercloud_lb_pool" "elb_pool_fleetmanager" {
  name        = "elb_pool_fleetmanager"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_fleetmanager.id
}

# Члены пулов (Member)
resource "sbercloud_lb_member" "elb_member_appgateway01" {
  pool_id       = sbercloud_lb_pool.elb_pool_appgateway.id
  address       = sbercloud_compute_instance.appgateway1.access_ip_v4
  protocol_port = 60003
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_appgateway02" {
  pool_id       = sbercloud_lb_pool.elb_pool_appgateway.id
  address       = sbercloud_compute_instance.appgateway2.access_ip_v4
  protocol_port = 60003
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_aass" {
  count         = 2
  pool_id       = sbercloud_lb_pool.elb_pool_aass.id
  address       = sbercloud_compute_instance.aass[count.index].access_ip_v4
  protocol_port = 9091
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_fleetmanager" {
  count         = 2
  pool_id       = sbercloud_lb_pool.elb_pool_fleetmanager.id
  address       = sbercloud_compute_instance.fleetmanager[count.index].access_ip_v4
  protocol_port = 31002
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

# Мониторы состояния (Health Monitor)
resource "sbercloud_lb_monitor" "elb_monitor_appgateway" {
  pool_id     = sbercloud_lb_pool.elb_pool_appgateway.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_aass" {
  pool_id     = sbercloud_lb_pool.elb_pool_aass.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_fleetmanager" {
  pool_id     = sbercloud_lb_pool.elb_pool_fleetmanager.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}