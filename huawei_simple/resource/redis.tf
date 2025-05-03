# Экземпляр Redis (DCS)
resource "huaweicloud_dcs_instance" "redis_instance" {
  name               = var.redis_name
  engine             = "Redis"
  engine_version     = "5.0"
  capacity           = var.redis_capacity
  flavor             = data.huaweicloud_dcs_flavors.dcs_flavors.flavors[0].name
  availability_zones = [
    data.huaweicloud_availability_zones.az.names[0],
    data.huaweicloud_availability_zones.az.names[1]
  ]
  password           = var.redis_password
  vpc_id             = huaweicloud_vpc.vpc.id
  subnet_id          = huaweicloud_vpc_subnet.subnet.id
  whitelist_enable   = false

  backup_policy {
    backup_type = "auto"                                    # Авто-бэкап
    save_days   = 3                                          # Хранить 3 дня
    backup_at   = [1,3,5,7]                                  # Дни недели
    begin_at    = "02:00-04:00"                              # Время
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}