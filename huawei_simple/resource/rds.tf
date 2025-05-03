# RDS-инстанс (HA или одиночный)
resource "huaweicloud_rds_instance" "rds_ha_instance" {
  count             = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 1 : 0   # Если flavor заканчивается на .ha → HA-инстанс
  name              = var.rds_name                                               # Имя инстанса
  availability_zone = [                                                          # Зоны доступности
    data.huaweicloud_availability_zones.az.names[0],
    data.huaweicloud_availability_zones.az.names[1]
  ]
  flavor            = var.rds_flavor                                              # Спецификация
  vpc_id            = huaweicloud_vpc_subnet.subnet.vpc_id                        # ID VPC
  subnet_id         = huaweicloud_vpc_subnet.subnet.id                            # ID подсети
  security_group_id = huaweicloud_networking_secgroup.secgroup.id                 # SG ID

  backup_strategy {
    keep_days  = 7                                                               # Сохранять бэкапы 7 дней
    start_time = "02:00-03:00"                                                   # Окно бэкапа
  }

  ha_replication_mode = "async"                                                  # Асинхронная репликация

  db {
    type     = "MySQL"                                                            # Тип СУБД
    version  = "5.7"                                                              # Версия
    password = var.rds_password                                                   # Пароль
  }

  volume {
    size = var.rds_volume_size                                                    # Размер тома (ГБ)
    type = "CLOUDSSD"                                                             # Тип хранилища
  }
}

resource "huaweicloud_rds_instance" "rds_single_instance" {
  count             = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 0 : 1   # Если нет .ha → одиночный инстанс
  name              = var.rds_name
  availability_zone = [ data.huaweicloud_availability_zones.az.names[0] ]
  flavor            = var.rds_flavor
  vpc_id            = huaweicloud_vpc_subnet.subnet.vpc_id
  subnet_id         = huaweicloud_vpc_subnet.subnet.id
  security_group_id = huaweicloud_networking_secgroup.secgroup.id

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
resource "huaweicloud_rds_database" "appgateway_database" {
  instance_id   = data.huaweicloud_rds_instances.rds_instance.instances[0].id  # Привязка к инстансу
  name          = "appgateway"                                                # Имя БД
  character_set = "utf8mb4"                                                    # Кодировка
}

resource "huaweicloud_rds_database" "aass_database" {
  instance_id   = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  name          = "aass"
  character_set = "utf8mb4"
}

resource "huaweicloud_rds_database" "fleetmanager_database" {
  instance_id   = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  name          = "fleetmanager"
  character_set = "utf8mb4"
}

# Создание MySQL-пользователей
resource "huaweicloud_rds_mysql_account" "user_appgateway" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  name        = "appgateway"
  password    = var.rds_password
}

resource "huaweicloud_rds_mysql_account" "user_aass" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  name        = "aass"
  password    = var.rds_password
}

resource "huaweicloud_rds_mysql_account" "user_fleetmanager" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  name        = "fleetmanager"
  password    = var.rds_password
}

# Назначение привилегий на БД
resource "huaweicloud_rds_mysql_database_privilege" "fleetmanager_database_privilege" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  db_name     = huaweicloud_rds_database.fleetmanager_database.name
  users {
    name     = huaweicloud_rds_mysql_account.user_fleetmanager.name
    readonly = false
  }
}

resource "huaweicloud_rds_mysql_database_privilege" "aass_database_privilege" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  db_name     = huaweicloud_rds_database.aass_database.name
  users {
    name     = huaweicloud_rds_mysql_account.user_aass.name
    readonly = false
  }
}

resource "huaweicloud_rds_mysql_database_privilege" "appgateway_database_privilege" {
  instance_id = data.huaweicloud_rds_instances.rds_instance.instances[0].id
  db_name     = huaweicloud_rds_database.appgateway_database.name
  users {
    name     = huaweicloud_rds_mysql_account.user_appgateway.name
    readonly = false
  }
}

