# Данные зон доступности
data "huaweicloud_availability_zones" "az" {}

# Данные образа CentOS
data "huaweicloud_images_image" "centos" {
  name        = "CentOS 7.9 64bit"   # Имя образа
  visibility  = "public"             # Видимость образа
  most_recent = true                 # Выбрать самый свежий
}

# Данные спецификаций DCS (Redis)
data "huaweicloud_dcs_flavors" "dcs_flavors" {
  engine_version = "5.0"                 # Версия движка
  cache_mode     = "ha"                  # Режим кэширования (HA)
  capacity       = var.redis_capacity    # Объём памяти (GB)
}

# Данные существующих экземпляров RDS
data "huaweicloud_rds_instances" "rds_instance" {
  depends_on = [
    huaweicloud_rds_instance.rds_single_instance,
    huaweicloud_rds_instance.rds_ha_instance
  ]

  name           = var.rds_name                   # Имя RDS-инстанса
  datastore_type = "MySQL"                        # Тип СУБД
  vpc_id         = huaweicloud_vpc_subnet.subnet.vpc_id  # ID VPC
  subnet_id      = huaweicloud_vpc_subnet.subnet.id     # ID подсети
}

# Локальные переменные
locals {
  az = [
    data.huaweicloud_availability_zones.az.names[0],  # Первая зона
    data.huaweicloud_availability_zones.az.names[1]   # Вторая зона
  ]
}