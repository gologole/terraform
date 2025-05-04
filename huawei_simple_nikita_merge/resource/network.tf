# Создание VPC
resource "sbercloud_vpc" "vpc" {
  name = var.vpc_name
  cidr = "192.168.0.0/16"
}

# Создание подсети
resource "sbercloud_vpc_subnet" "subnet" {
  name              = "${var.vpc_name}-subnet"
  cidr              = "192.168.1.0/24"
  gateway_ip        = "192.168.1.1"
  vpc_id            = sbercloud_vpc.vpc.id
  availability_zone = data.sbercloud_availability_zones.az.names[0]
}

# Группа IP-адресов
resource "sbercloud_vpc_address_group" "ipgroup" {
  name        = "GameFlexMatch_ipGroup"
  description = "Разрешить взаимный доступ сетей Appgateway и Auxproxy"
  addresses = [
    sbercloud_vpc_eip.eip[0].address,
    sbercloud_vpc_eip.eip[1].address,
    sbercloud_vpc_eip.eip[7].address
  ]
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

# Группа серверов с политикой антиаффинности
resource "sbercloud_compute_servergroup" "servergroup" {
  name     = "${var.ecs_name}-servergroup"
  policies = ["anti-affinity"]
}
