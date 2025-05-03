# Группа безопасности
resource "huaweicloud_networking_secgroup" "secgroup" {
  name = var.security_group_name  # Имя группы безопасности
}

# Правила группы безопасности
resource "huaweicloud_networking_secgroup_rule" "allow_ping" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить ICMP ping для проверки доступности серверов"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "allow_ssh_linux" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить SSH-доступ к Linux-серверам"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 22
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_mysql" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к MySQL"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 3306
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_appgateway" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту Appgateway"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 60003
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_component_mutual_access" {
  security_group_id            = huaweicloud_networking_secgroup.secgroup.id
  description                  = "Разрешить взаимный доступ между Appgateway и Auxproxy"
  direction                    = "ingress"
  ethertype                    = "IPv4"
  protocol                     = "tcp"
  ports                        = 60003
  remote_address_group_id      = huaweicloud_vpc_address_group.ipgroup.id
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_aass" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту AASS"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 9091
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_fleetmanager" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к компоненту Fleetmanager"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 31002
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_redis" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к Redis"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 6379
  remote_ip_prefix  = huaweicloud_vpc_subnet.subnet.cidr
}

resource "huaweicloud_networking_secgroup_rule" "allow_accessing_console" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к платформе управления GameFlexMatch"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_networking_secgroup_rule" "allow_elb_accessing_ecs" {
  security_group_id = huaweicloud_networking_secgroup.secgroup.id
  description       = "Разрешить доступ к бэкэнд-серверам через ELB"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "100.125.0.0/16"
}