# GaussDB for InfluxDB
resource "huaweicloud_gaussdb_influx_instance" "gaussdb_influx_instance" {
  name               = var.influx_name
  password           = var.influx_password
  flavor             = var.influx_flavor
  volume_size        = var.influx_volume_size
  vpc_id             = huaweicloud_vpc.vpc.id
  subnet_id          = huaweicloud_vpc_subnet.subnet.id
  security_group_id  = huaweicloud_networking_secgroup.secgroup.id
  availability_zone  = "cn-north-4a,cn-north-4b,cn-north-4c"   # Зоны через запятую
  ssl                = true

  backup_strategy {
    start_time = "03:00-04:00"                                # Окно бэкапа
    keep_days  = 14                                           # Сохранять 14 дней
  }

  datastore {
    engine         = "influxdb"                               # Движок
    version        = 1.7                                      # Версия
    storage_engine = "rocksDB"                                # Хранилище
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}