# Данные зон доступности
data "sbercloud_availability_zones" "az" {}  # :contentReference[oaicite:6]{index=6}

# Данные образа CentOS
data "sbercloud_images_image" "centos" {     # :contentReference[oaicite:7]{index=7}
  name        = "CentOS 7.9 64bit"
  visibility  = "public"
  most_recent = true
}

# Данные спецификаций DCS (Redis)
data "sbercloud_dcs_flavors" "dcs_flavors" { # :contentReference[oaicite:8]{index=8}
  engine_version = "5.0"
  cache_mode     = "ha"
  capacity       = var.redis_capacity
}

# Данные существующих экземпляров RDS
data "sbercloud_rds_instances" "rds_instance" { # :contentReference[oaicite:9]{index=9}
  depends_on = [
    sbercloud_rds_instance.rds_single_instance,
    sbercloud_rds_instance.rds_ha_instance,
  ]

  name           = var.rds_name
  datastore_type = "MySQL"
  vpc_id         = sbercloud_vpc_subnet.subnet.vpc_id
  subnet_id      = sbercloud_vpc_subnet.subnet.id
}

# Локальные переменные
locals {
  az = [
    data.sbercloud_availability_zones.az.names[0],
    data.sbercloud_availability_zones.az.names[1],
  ]  # :contentReference[oaicite:10]{index=10}
}
