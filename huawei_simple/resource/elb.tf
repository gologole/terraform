# Балансировщики нагрузки (ELB)
resource "huaweicloud_lb_loadbalancer" "elb_appgateway" {
  name          = "${var.elb_name}_appgateway"               # Имя ELB для Appgateway
  vip_subnet_id = huaweicloud_vpc_subnet.subnet.id           # Подсеть VIP
}

resource "huaweicloud_lb_loadbalancer" "elb_aass" {
  name          = "${var.elb_name}_aass"
  vip_subnet_id = huaweicloud_vpc_subnet.subnet.id
}

resource "huaweicloud_lb_loadbalancer" "elb_fleetmanager" {
  name          = "${var.elb_name}_fleetmanager"
  vip_subnet_id = huaweicloud_vpc_subnet.subnet.id
}

# Слушатели ELB (Listener)
resource "huaweicloud_lb_listener" "elb_listener_appgateway" {
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb_appgateway.id   # ID балансировщика Appgateway
  protocol        = "TCP"                                           # Протокол
  protocol_port   = 60003                                           # Порт
}

resource "huaweicloud_lb_listener" "elb_listener_aass" {
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb_aass.id         # ID балансировщика AASS
  protocol        = "TCP"
  protocol_port   = 9091
}

resource "huaweicloud_lb_listener" "elb_listener_fleetmanager" {
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb_fleetmanager.id # ID балансировщика Fleetmanager
  protocol        = "TCP"
  protocol_port   = 31002
}

# Пулы бекенд‑серверов (Pool)
resource "huaweicloud_lb_pool" "elb_pool_appgateway" {
  name        = "elb_pool_appgateway"                               # Имя пула
  protocol    = "TCP"                                               # Протокол
  lb_method   = "ROUND_ROBIN"                                       # Алгоритм балансировки
  listener_id = huaweicloud_lb_listener.elb_listener_appgateway.id  # Привязка к слушателю
}

resource "huaweicloud_lb_pool" "elb_pool_aass" {
  name        = "elb_pool_aass"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.elb_listener_aass.id
}

resource "huaweicloud_lb_pool" "elb_pool_fleetmanager" {
  name        = "elb_pool_fleetmanager"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.elb_listener_fleetmanager.id
}

# Члены пулов (Member)
resource "huaweicloud_lb_member" "elb_member_appgateway01" {
  pool_id       = huaweicloud_lb_pool.elb_pool_appgateway.id   # ID пула Appgateway
  address       = huaweicloud_compute_instance.appgateway1.access_ip_v4
  protocol_port = 60003
  subnet_id     = huaweicloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "huaweicloud_lb_member" "elb_member_appgateway02" {
  pool_id       = huaweicloud_lb_pool.elb_pool_appgateway.id
  address       = huaweicloud_compute_instance.appgateway2.access_ip_v4
  protocol_port = 60003
  subnet_id     = huaweicloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "huaweicloud_lb_member" "elb_member_aass" {
  count         = 2
  pool_id       = huaweicloud_lb_pool.elb_pool_aass.id         # ID пула AASS
  address       = huaweicloud_compute_instance.aass[count.index].access_ip_v4
  protocol_port = 9091
  subnet_id     = huaweicloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "huaweicloud_lb_member" "elb_member_fleetmanager" {
  count         = 2
  pool_id       = huaweicloud_lb_pool.elb_pool_fleetmanager.id # ID пула Fleetmanager
  address       = huaweicloud_compute_instance.fleetmanager[count.index].access_ip_v4
  protocol_port = 31002
  subnet_id     = huaweicloud_vpc_subnet.subnet.id
  weight        = 1
}

# Мониторы состояния (Health Monitor)
resource "huaweicloud_lb_monitor" "elb_monitor_appgateway" {
  pool_id    = huaweicloud_lb_pool.elb_pool_appgateway.id   # ID пула Appgateway
  type       = "TCP"                                        # Тип проверки
  delay      = 5                                            # Интервал в секундах
  timeout    = 3                                            # Время таймаута
  max_retries = 3                                           # Количество повторных попыток
}

resource "huaweicloud_lb_monitor" "elb_monitor_aass" {
  pool_id    = huaweicloud_lb_pool.elb_pool_aass.id
  type       = "TCP"
  delay      = 5
  timeout    = 3
  max_retries = 3
}

resource "huaweicloud_lb_monitor" "elb_monitor_fleetmanager" {
  pool_id    = huaweicloud_lb_pool.elb_pool_fleetmanager.id
  type       = "TCP"
  delay      = 5
  timeout    = 3
  max_retries = 3
}