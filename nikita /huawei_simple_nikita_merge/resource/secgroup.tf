# Группа безопасности
resource "sbercloud_networking_secgroup" "secgroup" {
  name = var.security_group_name  # Имя группы безопасности
}

# Правила группы безопасности

# Разрешить ICMP ping для проверки доступности серверов
resource "sbercloud_networking_secgroup_rule" "allow_ping" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить ICMP ping для проверки доступности серверов"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

# Разрешить SSH-доступ к Linux-серверам
resource "sbercloud_networking_secgroup_rule" "allow_ssh_linux" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить SSH-доступ к Linux-серверам"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить доступ к MySQL
resource "sbercloud_networking_secgroup_rule" "allow_accessing_mysql" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к MySQL"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить доступ к компоненту Appgateway
resource "sbercloud_networking_secgroup_rule" "allow_accessing_appgateway" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту Appgateway"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 60003
  port_range_max    = 60003
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить взаимный доступ между Appgateway и Auxproxy
resource "sbercloud_networking_secgroup_rule" "allow_component_mutual_access" {
  security_group_id       = sbercloud_networking_secgroup.secgroup.id
  description             = "Разрешить взаимный доступ между Appgateway и Auxproxy"
  direction               = "ingress"
  ethertype               = "IPv4"
  protocol                = "tcp"
  port_range_min          = 60003
  port_range_max          = 60003
  remote_address_group_id = sbercloud_vpc_address_group.ipgroup.id
}

# Разрешить доступ к компоненту AASS
resource "sbercloud_networking_secgroup_rule" "allow_accessing_aass" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту AASS"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9091
  port_range_max    = 9091
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить доступ к компоненту Fleetmanager
resource "sbercloud_networking_secgroup_rule" "allow_accessing_fleetmanager" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту Fleetmanager"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 31002
  port_range_max    = 31002
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить доступ к Redis
resource "sbercloud_networking_secgroup_rule" "allow_accessing_redis" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к Redis"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6379
  port_range_max    = 6379
  remote_ip_prefix  = sbercloud_vpc_subnet.subnet.cidr
}

# Разрешить доступ к платформе управления GameFlexMatch
resource "sbercloud_networking_secgroup_rule" "allow_accessing_console" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к платформе управления GameFlexMatch"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# Разрешить доступ к бэкэнд-серверам через ELB
resource "sbercloud_networking_secgroup_rule" "allow_elb_accessing_ecs" {
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к бэкэнд-серверам через ELB"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "100.125.0.0/16"
}
