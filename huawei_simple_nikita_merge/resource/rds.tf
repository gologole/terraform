# RDS-инстанс (HA или одиночный)
resource "sbercloud_rds_instance" "rds_instance" {
  count             = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 1 : 0
  name              = var.rds_name
  availability_zone = [
    data.sbercloud_availability_zones.az.names[0],
    data.sbercloud_availability_zones.az.names[1]
  ]
  flavor            = var.rds_flavor
  vpc_id            = sbercloud_vpc_subnet.subnet.vpc_id
  subnet_id         = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id

  backup_strategy {
    keep_days  = 7
    start_time = "02:00-03:00"
  }

  ha_replication_mode = "async"

  db {
    type     = "MySQL"
    version  = "5.7"
    password = var.rds_password
  }

  volume {
    size = var.rds_volume_size
    type = "CLOUDSSD"
  }
}

resource "sbercloud_rds_instance" "rds_single_instance" {
  count             = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 0 : 1
  name              = var.rds_name
  availability_zone = [data.sbercloud_availability_zones.az.names[0]]
  flavor            = var.rds_flavor
  vpc_id            = sbercloud_vpc_subnet.subnet.vpc_id
  subnet_id         = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id

  backup_strategy {
    keep_days  = 7
    start_time = "02:00-03:00"
  }

  db {
    type     = "MySQL"
    version  = "5.7"
    password = var.rds_password
  }

  volume {
    size = var.rds_volume_size
    type = "CLOUDSSD"
  }
}

# Создание баз данных в RDS
resource "sbercloud_rds_mysql_database" "appgateway_database" {
  instance_id   = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name          = "appgateway"
  character_set = "utf8mb4"
}

resource "sbercloud_rds_mysql_database" "aass_database" {
  instance_id   = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name          = "aass"
  character_set = "utf8mb4"
}

resource "sbercloud_rds_mysql_database" "fleetmanager_database" {
  instance_id   = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name          = "fleetmanager"
  character_set = "utf8mb4"
}

# Создание MySQL-пользователей
resource "sbercloud_rds_mysql_account" "user_appgateway" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name        = "appgateway"
  password    = var.rds_password
}

resource "sbercloud_rds_mysql_account" "user_aass" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name        = "aass"
  password    = var.rds_password
}

resource "sbercloud_rds_mysql_account" "user_fleetmanager" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  name        = "fleetmanager"
  password    = var.rds_password
}

# Назначение привилегий на БД
resource "sbercloud_rds_mysql_database_privilege" "fleetmanager_database_privilege" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  db_name     = sbercloud_rds_mysql_database.fleetmanager_database.name
  users {
    name     = sbercloud_rds_mysql_account.user_fleetmanager.name
    readonly = false
  }
}

resource "sbercloud_rds_mysql_database_privilege" "aass_database_privilege" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  db_name     = sbercloud_rds_mysql_database.aass_database.name
  users {
    name     = sbercloud_rds_mysql_account.user_aass.name
    readonly = false
  }
}

resource "sbercloud_rds_mysql_database_privilege" "appgateway_database_privilege" {
  instance_id = data.sbercloud_rds_instances.rds_instance.instances[0].id
  db_name     = sbercloud_rds_mysql_database.appgateway_database.name
  users {
    name     = sbercloud_rds_mysql_account.user_appgateway.name
    readonly = false
  }
}
