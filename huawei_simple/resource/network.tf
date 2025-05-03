# Создание VPC
resource "huaweicloud_vpc" "vpc" {
  name = var.vpc_name         # Имя VPC
  cidr = "192.168.0.0/16"     # CIDR-блок
}

# Создание подсети
resource "huaweicloud_vpc_subnet" "subnet" {
  availability_zone = data.huaweicloud_availability_zones.az.names[0]  # Зона доступности
  name              = "${var.vpc_name}-subnet"                       # Имя подсети
  cidr              = "192.168.1.0/24"                               # CIDR-подсети
  gateway_ip        = "192.168.1.1"                                  # IP шлюза
  vpc_id            = huaweicloud_vpc.vpc.id                         # ID VPC
}

# Группа адресов для Appgateway и Auxproxy
resource "huaweicloud_vpc_address_group" "ipgroup" {
  description = "Разрешить взаимный доступ сетей Appgateway и Auxproxy"
  name        = "GameFlexMatch_ipGroup"
  addresses = [
    huaweicloud_vpc_eip.eip[0].address,
    huaweicloud_vpc_eip.eip[1].address,
    huaweicloud_vpc_eip.eip[7].address
  ]
}

# Выделенные публичные IP для VPC
resource "huaweicloud_vpc_eip" "eip" {
  count         = 9                                    # Количество EIP
  name          = "${var.vpc_name}-eip"               # Имя EIP
  bandwidth {
    name        = "${var.vpc_name}-bandwidth"          # Имя полосы пропускания
    share_type  = "PER"                                # Тип шаринга (PER – выделенная полоса)
    size        = var.eip_bandwidth_size               # Размер полосы (Мбит/с)
    charge_mode = "bandwidth"                          # Режим тарификации по полосе
  }
  publicip {
    type = "5_bgp"                                     # Тип публичного IP
  }
  charging_mode = var.charge_mode                      # Режим оплаты (postPaid/prePaid)
  period_unit   = var.charge_period_unit               # Единица периода оплаты (month/year)
  period        = var.charge_period                    # Длительность периода оплаты
}

# Группа серверов (Anti‑Affinity)
resource "huaweicloud_compute_servergroup" "servergroup" {
  name     = "${var.ecs_name}-servergroup"             # Имя группы серверов
  policies = ["anti-affinity"]                         # Политика – не размещать вместе
}