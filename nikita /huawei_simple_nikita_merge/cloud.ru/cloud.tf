variable "enterprise_project_id" {
  type        = string
  default     = "0"
  description = "ID корпоративного проекта, см. руководство по развертыванию на странице управления проектами https://console.huaweicloud.com/eps/, 0 означает проект по умолчанию. По умолчанию 0."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}$|^0$", var.enterprise_project_id)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "vpc_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя виртуальной частной сети (VPC). Шаблон создаёт новый VPC, дублирование имён не допускается. Допустимая длина: 1–54 символа, поддерживаются цифры, буквы, китайские символы, подчёркивание (_), дефис (-) и точка (.). По умолчанию gameflexmatch-hosting-platform-demo."
  nullable    = false
}

variable "security_group_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя группы безопасности. Шаблон создаёт новую группу безопасности; правила смотрите в руководстве по развертыванию. Допустимая длина: 1–64 символа, поддерживаются цифры, буквы, китайские символы, подчёркивание (_), дефис (-) и точка (.). По умолчанию gameflexmatch-hosting-platform-demo."
  nullable    = false
}

variable "eip_bandwidth_size" {
  type        = number
  default     = 5
  description = "Ширина полосы пропускания эластичного публичного IP (EIP) в Мбит/с; оплата по ширине канала. Диапазон: 1–2000. По умолчанию 5."
  nullable    = false

  validation {
    condition     = length(regexall("^([1-9]|[1-9]\\d{1,2}|1\\d{3}|2000)$", var.eip_bandwidth_size)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "obs_bucket_name" {
  type        = string
  default     = ""
  description = "Префикс имени корзины OBS, формат: {obs_bucket_name}-obs; для хранения данных приложения, дублирование имён не допускается. Длина: 1–59 символов; должно начинаться и заканчиваться буквой или цифрой; поддерживаются строчные буквы, цифры, дефис (-) и точка (.)."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-z0-9][a-z0-9\\.-]{0,57}[a-z0-9]$", var.obs_bucket_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "elb_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс имени ELB; формат: {elb_name}_appgateway, {elb_name}_aass, {elb_name}_fleetmanager. Длина: 1–51 символ; поддерживаются китайские символы, латинские буквы, цифры, подчёркивание (_), дефис (-) и точка (.)."
  nullable    = false
}

variable "domain_id" {
  type        = string
  default     = ""
  description = "ID учётной записи; см. руководство по развертыванию. Длина: 32 символа; только строчные латинские буквы и цифры."
  nullable    = false
  sensitive   = true

  validation {
    condition     = length(regexall("^[a-z0-9]{32}$", var.domain_id)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "access_key" {
  type        = string
  default     = ""
  description = "Ключ доступа (AK) для идентификации; используется при создании ресурсов и загрузке конфигураций в OBS и управления GameFlexMatch. Длина: 20 символов; только заглавные латинские буквы и цифры."
  nullable    = false
  sensitive   = true

  validation {
    condition     = length(regexall("^[A-Z0-9]{20}$", var.access_key)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "secret_access_key" {
  type        = string
  default     = ""
  description = "Секретный ключ (SK) для подписи запросов; используется при создании ресурсов и загрузке конфигураций в OBS и управления GameFlexMatch. Длина: 40 символов; только латинские буквы и цифры."
  nullable    = false
  sensitive   = true

  validation {
    condition     = length(regexall("^[A-Za-z0-9]{40}$", var.secret_access_key)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "iam_agency_name" {
  type        = string
  default     = ""
  description = "Имя доверенного агентства IAM; дублирование не допускается. Для установки ICAgent и экспорта логов в LTS. Длина: 1–59 символов; поддерживаются буквы, цифры, пробелы и спецсимволы - _ . ,."
  nullable    = false

  validation {
    condition     = length(regexall("^[\\w\\s-\\.,]{1,59}$", var.iam_agency_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}



variable "charge_mode" {
  type        = string
  default     = "postPaid"
  description = "Режим оплаты; по умолчанию postPaid (оплата по факту). Опции: postPaid, prePaid (год/месяц)."
  nullable    = false

  validation {
    condition     = contains(["postPaid", "prePaid"], var.charge_mode)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "charge_period_unit" {
  type        = string
  default     = "month"
  description = "Единица периода оплаты; действует только для prePaid. Опции: month (месяц), year (год)."
  nullable    = false

  validation {
    condition     = contains(["month", "year"], var.charge_period_unit)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "charge_period" {
  type        = number
  default     = 1
  description = "Период оплаты; действует только для prePaid. При month: 1–9; при year: 1–3. По умолчанию 1."
  nullable    = false

  validation {
    condition     = length(regexall("^[1-9]$", var.charge_period)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс имени ECS в SberCloud; формат: {prefix}-appgateway0X, {prefix}-aass0X, {prefix}-fleetmanager0X и {prefix}-console, где X = 1 или 2. Длина 1–49 символов; допустимы буквы, цифры, '_', '-' и '.'."
  validation {
    condition     = length(regexall("^[\\w-.]{1,49}$", var.ecs_name)) > 0
    error_message = "ecs_name должен содержать 1–49 символов: буквы, цифры, '_', '-' или '.'."
  }
}

variable "ecs_flavor" {
  type        = string
  default     = "c7.large.2"
  description = "Название flavor для ECS в SberCloud (минимум 2 vCPU и 4 GB). Список доступных можно посмотреть в настройках AS configuration or EVS volume resources провайдера. По умолчанию c7.large.2."
  validation {
    condition     = length(regexall("^[a-z][a-z0-9]{0,3}\\.(x[1-9]|[1-9][0-9]x?)large\\.[1-9][0-9]?$", var.ecs_flavor)) > 0
    error_message = "ecs_flavor должен соответствовать шаблону типа c{generation}.{size}.X (например, c7.large.2)."
  }
}

variable "ecs_password" {
  type        = string
  default     = ""
  description = "Пароль для root в ECS и Console SberCloud; длина 8–26 символов; минимум три из четырёх групп: заглавные, строчные, цифры, спецсимволы (!@$%?*#.). Пароль не должен содержать имя пользователя или обратную запись."
  sensitive   = true
  validation {
    condition = (
      length(var.ecs_password) >= 8 &&
    length(var.ecs_password) <= 26)
    error_message = "ecs_password должен быть 8–26 символов и содержать не менее трёх типов символов: заглавные, строчные, цифры или спецсимволы (!@$%?*#.)."
  }
}

variable "ecs_disk_size" {
  type        = number
  default     = 100
  description = "Размер системного EVS-диска (SSD) для ECS в ГБ; диапазон: 40–1024 ГБ, шаг — 10 ГБ. Уменьшение размера после создания не поддерживается."
  validation {
    condition     = var.ecs_disk_size >= 40 && var.ecs_disk_size <= 1024 && var.ecs_disk_size % 10 == 0
    error_message = "ecs_disk_size должен быть числом от 40 до 1024, кратным 10."
  }
}

variable "influx_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя экземпляра GaussDB (InfluxDB); диапазон: 4–64 символа; начинается с буквы; поддерживаются цифры, буквы, подчёркивание (_) и дефис (-)."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.influx_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "influx_flavor" {
  type        = string
  default     = "geminidb.influxdb.large.4"
  description = "Спецификация GaussDB (InfluxDB); см. https://support.huaweicloud.com/influxug-nosql/nosql_05_0045.html. По умолчанию geminidb.influxdb.large.4 (2vCPU, 8GB)."
  nullable    = false

  validation {
    condition = contains([
      "geminidb.influxdb.large.4",
      "geminidb.influxdb.xlarge.4",
      "geminidb.influxdb.2xlarge.4",
      "geminidb.influxdb.4xlarge.4",
      "geminidb.influxdb.8xlarge.4"
    ], var.influx_flavor)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "influx_volume_size" {
  type        = number
  default     = 100
  description = "Размер хранилища GaussDB (InfluxDB) в ГБ; диапазон: 100–12000. По умолчанию 100."
  nullable    = false

  validation {
    condition     = length(regexall("^([1-9][0-9]{2,3}|1[0-1][0-9]{3}|12000)$", var.influx_volume_size)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "influx_password" {
  type        = string
  default     = ""
  description = "Пароль инициализации GaussDB (InfluxDB); длина: 8–32 символа; заглавные, строчные, цифры и спецсимволы ~!@#%^*-_=+?; админ: rwuser."
  nullable    = false
  sensitive   = true
  validation {
    condition = (
      length(var.influx_password) >= 8 &&
    length(var.influx_password) <= 32)
    error_message = "influx_password должен быть 8–32 символа и содержать не менее трёх типов: заглавные, строчные, цифры или спецсимволы."
  }
}

variable "influxdb_cluster_name" {
  type        = string
  default     = "influxdb-cluster"
  description = "Базовое имя для узлов кластера InfluxDB"
}

variable "influxdb_instance_count" {
  type        = number
  default     = 3
  description = "Количество узлов в кластере InfluxDB"
}

variable "influxdb_disk_size" {
  type        = number
  default     = 100
  description = "Размер диска для каждого узла InfluxDB в ГБ"
  validation {
    condition     = var.influxdb_disk_size >= 40 && var.influxdb_disk_size <= 32768
    error_message = "Размер диска должен быть от 40 до 32768 ГБ"
  }
}

variable "influxdb_flavor" {
  type        = string
  default     = "s6.large.2"
  description = "Тип виртуальной машины для узлов InfluxDB"
}

variable "influxdb_password" {
  type        = string
  sensitive   = true
  description = "Пароль для доступа к узлам кластера InfluxDB"
  validation {
    condition     = length(var.influxdb_password) >= 8 && length(var.influxdb_password) <= 32
    error_message = "Пароль должен быть от 8 до 32 символов"
  }
}

variable "rds_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя RDS for MySQL; дублирование не допускается. Длина: 4–64 символа; начинается с буквы; поддерживаются цифры, буквы, подчёркивание (_) и дефис (-)."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.rds_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_flavor" {
  type        = string
  default     = "rds.mysql.n1.large.2.ha"
  description = "Спецификация RDS; подробности см. https://support.huaweicloud.com/productdesc-rds/rds_01_0034.html. По умолчанию rds.mysql.n1.large.2.ha (2vCPU, 4GB, мастер-резерв)."
  nullable    = false

  validation {
    condition     = length(regexall("^(rds.mysql.)(n1.|x1.)(x|2x|4x|8x|16x||)large.((2|4|8).ha|(2|4|8))$", var.rds_flavor)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_volume_size" {
  type        = number
  default     = 100
  description = "Размер хранилища RDS в ГБ (SSD); диапазон: 40–4000, кратно 10. По умолчанию 100."
  nullable    = false

  validation {
    condition     = length(regexall("^([4-9]0|[1-9][0-9]0|[1-3][0-9]{2}0|4000)$", var.rds_volume_size)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_password" {
  type        = string
  default     = ""
  description = "Пароль root для RDS for MySQL; по умолчанию создаются БД appgateway, aass, fleetmanager и соответствующие пользователи с этим паролем. Длина: 8–32 символа; минимум три типа из: заглавные, строчные, цифры, спецсимволы (~!@#$%^*-_=+?,()&)."
  nullable    = false
  sensitive   = true
}

variable "redis_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя Redis (распределённый кеш); диапазон: 4–64 символа; начинается с буквы; поддерживаются цифры, буквы, подчёркивание (_) и дефис (-)."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.redis_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "redis_capacity" {
  type        = number
  default     = 2
  description = "Объём памяти кеша для Redis (ГБ); см. https://support.huaweicloud.com/productdesc-dcs/dcs-pd-0522002.html. По умолчанию 2."
  nullable    = false

  validation {
    condition     = contains([0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 24, 32, 48, 64], var.redis_capacity)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "redis_password" {
  type        = string
  default     = ""
  description = "Пароль инициализации Redis; длина: 8–32 символа; минимум три типа из: заглавные, строчные, цифры, спецсимволы ~!@#%^*-_=+?."
  nullable    = false
  sensitive   = true
}

variable "security_token" {
  type        = string
  default     = ""
  description = "Токен безопасности (STS), если используется"
  nullable    = false
}


# Данные зон доступности
data "sbercloud_availability_zones" "az" {} # :contentReference[oaicite:6]{index=6}

# Данные образа CentOS
data "sbercloud_images_image" "centos" { # :contentReference[oaicite:7]{index=7}
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
  ] # :contentReference[oaicite:10]{index=10}
}

# Привязка EIP к VIP порту AppGateway
resource "sbercloud_networking_eip_associate" "eip_associate_appgateway" {
  port_id   = sbercloud_lb_loadbalancer.elb_appgateway.vip_port_id # VIP порт AppGateway
  public_ip = sbercloud_vpc_eip.eip[7].address                     # Адрес EIP
}

# Привязка EIP к VIP порту FleetManager
resource "sbercloud_networking_eip_associate" "eip_associate_fleetmanager" {
  port_id   = sbercloud_lb_loadbalancer.elb_fleetmanager.vip_port_id # VIP порт FleetManager
  public_ip = sbercloud_vpc_eip.eip[8].address                       # Адрес EIP
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

# Балансировщики нагрузки (ELB)
resource "sbercloud_lb_loadbalancer" "elb_appgateway" {
  name          = "${var.elb_name}_appgateway"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

resource "sbercloud_lb_loadbalancer" "elb_aass" {
  name          = "${var.elb_name}_aass"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

resource "sbercloud_lb_loadbalancer" "elb_fleetmanager" {
  name          = "${var.elb_name}_fleetmanager"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

# Слушатели ELB (Listener)
resource "sbercloud_lb_listener" "elb_listener_appgateway" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_appgateway.id
  protocol        = "TCP"
  protocol_port   = 60003
}

resource "sbercloud_lb_listener" "elb_listener_aass" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_aass.id
  protocol        = "TCP"
  protocol_port   = 9091
}

resource "sbercloud_lb_listener" "elb_listener_fleetmanager" {
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_fleetmanager.id
  protocol        = "TCP"
  protocol_port   = 31002
}

# Пулы бекенд‑серверов (Pool)
resource "sbercloud_lb_pool" "elb_pool_appgateway" {
  name        = "elb_pool_appgateway"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_appgateway.id
}

resource "sbercloud_lb_pool" "elb_pool_aass" {
  name        = "elb_pool_aass"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_aass.id
}

resource "sbercloud_lb_pool" "elb_pool_fleetmanager" {
  name        = "elb_pool_fleetmanager"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_fleetmanager.id
}

# Члены пулов (Member)
resource "sbercloud_lb_member" "elb_member_appgateway01" {
  pool_id       = sbercloud_lb_pool.elb_pool_appgateway.id
  address       = sbercloud_compute_instance.appgateway01.access_ip_v4
  protocol_port = 60003
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_appgateway02" {
  pool_id       = sbercloud_lb_pool.elb_pool_appgateway.id
  address       = sbercloud_compute_instance.appgateway02.access_ip_v4
  protocol_port = 60003
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_aass" {
  count         = 2
  pool_id       = sbercloud_lb_pool.elb_pool_aass.id
  address       = sbercloud_compute_instance.aass[count.index].access_ip_v4
  protocol_port = 9091
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

resource "sbercloud_lb_member" "elb_member_fleetmanager" {
  count         = 2
  pool_id       = sbercloud_lb_pool.elb_pool_fleetmanager.id
  address       = sbercloud_compute_instance.fleetmanager[count.index].access_ip_v4
  protocol_port = 31002
  subnet_id     = sbercloud_vpc_subnet.subnet.id
  weight        = 1
}

# Мониторы состояния (Health Monitor)
resource "sbercloud_lb_monitor" "elb_monitor_appgateway" {
  pool_id     = sbercloud_lb_pool.elb_pool_appgateway.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_aass" {
  pool_id     = sbercloud_lb_pool.elb_pool_aass.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_fleetmanager" {
  pool_id     = sbercloud_lb_pool.elb_pool_fleetmanager.id
  type        = "TCP"
  delay       = 5
  timeout     = 3
  max_retries = 3
}

resource "sbercloud_identity_agency" "smn_agency" {
  name                   = var.iam_agency_name
  description            = "Агентство для SMN"
  delegated_service_name = "smn"
}

resource "sbercloud_identity_agency_role" "smn_agency_roles" {
  agency_id  = sbercloud_identity_agency.smn_agency.id
  project_id = var.project_id
  roles = [
    "SMN Administrator",
    "Tenant Guest"
  ]
}

# Создание системных дисков для узлов InfluxDB
resource "sbercloud_evs_volume" "influxdb_system_disks" {
  count             = 3
  name              = "${var.influxdb_cluster_name}-node${count.index + 1}-system-disk"
  description       = "Системный диск для узла InfluxDB ${count.index + 1}"
  size              = var.influxdb_disk_size
  volume_type       = "SSD"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % length(data.sbercloud_availability_zones.az.names)]
}

# Создание виртуальных машин для узлов InfluxDB
resource "sbercloud_compute_instance" "influxdb_nodes" {
  count              = 3
  name               = "${var.influxdb_cluster_name}-node${count.index + 1}"
  flavor_id          = var.influxdb_flavor
  image_id           = data.sbercloud_images_image.centos.id
  availability_zone  = data.sbercloud_availability_zones.az.names[count.index % length(data.sbercloud_availability_zones.az.names)]
  admin_pass         = var.influxdb_password
  security_group_ids = [sbercloud_networking_secgroup.secgroup.id]

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period

  user_data = <<-EOF
              #!/bin/bash
              # Установка и настройка InfluxDB
              curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
              echo "deb https://repos.influxdata.com/debian stable main" | sudo tee /etc/apt/sources.list.d/influxdb.list
              sudo apt-get update
              sudo apt-get install -y influxdb

              # Настройка конфигурации InfluxDB для кластера
              cat > /etc/influxdb/influxdb.conf <<EOL
              [meta]
                dir = "/var/lib/influxdb/meta"
                hostname = "${self.access_ip_v4}"
                bind-address = "${self.access_ip_v4}:8088"
                retention-autocreate = true
                election-timeout = "1s"
                heartbeat-timeout = "1s"
                leader-lease-timeout = "500ms"
                commit-timeout = "50ms"

              [data]
                dir = "/var/lib/influxdb/data"
                wal-dir = "/var/lib/influxdb/wal"
                query-log-enabled = true
                cache-max-memory-size = 1073741824
                cache-snapshot-memory-size = 26214400
                cache-snapshot-write-cold-duration = "10m"
                compact-full-write-cold-duration = "4h"

              [coordinator]
                write-timeout = "10s"
                max-concurrent-queries = 0
                query-timeout = "0s"
                log-queries-after = "0s"
                max-select-point = 0
                max-select-series = 0
                max-select-buckets = 0

              [retention]
                enabled = true
                check-interval = "30m"

              [shard-precreation]
                enabled = true
                check-interval = "10m"
                advance-period = "30m"

              [monitor]
                store-enabled = true
                store-database = "_internal"
                store-interval = "10s"

              [http]
                enabled = true
                bind-address = ":8086"
                auth-enabled = true
                log-enabled = true
                write-tracing = false
                pprof-enabled = true
                https-enabled = false
              EOL

              # Запуск InfluxDB
              sudo systemctl enable influxdb
              sudo systemctl start influxdb

              # Создание пользователя администратора
              sleep 10
              influx -execute "CREATE USER admin WITH PASSWORD '${var.influxdb_password}' WITH ALL PRIVILEGES"

              # Настройка кластера
              if [ ${count.index} -eq 0 ]; then
                # Первый узел - лидер
                influx -username admin -password '${var.influxdb_password}' -execute "CREATE DATABASE metrics"
              else
                # Остальные узлы - присоединяются к кластеру
                influx -username admin -password '${var.influxdb_password}' -execute "JOIN ${sbercloud_compute_instance.influxdb_nodes[0].access_ip_v4}:8088"
              fi
              EOF

  tags = {
    role = "influxdb-cluster"
    node = "node${count.index + 1}"
  }
}

# Прикрепление системных дисков к виртуальным машинам
resource "sbercloud_compute_volume_attach" "influxdb_volume_attachments" {
  count       = 3
  instance_id = sbercloud_compute_instance.influxdb_nodes[count.index].id
  volume_id   = sbercloud_evs_volume.influxdb_system_disks[count.index].id
}

# Создание правил безопасности для InfluxDB
resource "sbercloud_networking_secgroup_rule" "influxdb_cluster_rules" {
  count             = length(local.influxdb_ports)
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = local.influxdb_ports[count.index]
  port_range_max    = local.influxdb_ports[count.index]
  remote_group_id   = sbercloud_networking_secgroup.secgroup.id
}

locals {
  influxdb_ports = [8086, 8088] # 8086 для HTTP API, 8088 для кластерной коммуникации
}

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

# Группа серверов с политикой антиаффинности
resource "sbercloud_compute_servergroup" "servergroup" {
  name     = "${var.ecs_name}-servergroup"
  policies = ["anti-affinity"]
}

# Корзина OBS для хранения данных
resource "sbercloud_obs_bucket" "bucket" {
  bucket   = "${var.obs_bucket_name}-obs"
  acl      = "private"
  multi_az = false
}


# RDS-инстанс (HA или одиночный)
resource "sbercloud_rds_instance" "rds_instance" {
  count = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 1 : 0
  name  = var.rds_name
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

resource "sbercloud_rds_instance" "rds_ha_instance" {
  count = length(regexall(".*\\.ha$", var.rds_flavor)) > 0 ? 1 : 0 # Если flavor заканчивается на .ha → HA-инстанс
  name  = var.rds_name                                             # Имя инстанса
  availability_zone = [                                            # Зоны доступности
    data.huaweicloud_availability_zones.az.names[0],
    data.huaweicloud_availability_zones.az.names[1]
  ]
  flavor            = var.rds_flavor                              # Спецификация
  vpc_id            = huaweicloud_vpc_subnet.subnet.vpc_id        # ID VPC
  subnet_id         = huaweicloud_vpc_subnet.subnet.id            # ID подсети
  security_group_id = huaweicloud_networking_secgroup.secgroup.id # SG ID

  backup_strategy {
    keep_days  = 7             # Сохранять бэкапы 7 дней
    start_time = "02:00-03:00" # Окно бэкапа
  }

  ha_replication_mode = "async" # Асинхронная репликация

  db {
    type     = "MySQL"          # Тип СУБД
    version  = "5.7"            # Версия
    password = var.rds_password # Пароль
  }

  volume {
    size = var.rds_volume_size # Размер тома (ГБ)
    type = "CLOUDSSD"          # Тип хранилища
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


resource "sbercloud_dcs_instance" "redis_instance" {
  name               = var.redis_name
  engine             = "Redis"
  engine_version     = "5.0"
  capacity           = var.redis_capacity
  flavor             = var.redis_flavor
  availability_zones = var.availability_zones
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  security_group_id  = var.security_group_id
  password           = var.redis_password
  whitelist_enable   = false

  backup_policy {
    backup_type = "auto"
    save_days   = 3
    backup_at   = [1, 3, 5, 7]
    begin_at    = "02:00-04:00"
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}


# Группа безопасности
resource "sbercloud_networking_secgroup" "secgroup" {
  name = var.security_group_name # Имя группы безопасности
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

# Создание системного диска для Appgateway01
resource "sbercloud_evs_volume" "appgateway01_sysdisk" {
  name              = "${var.ecs_name}-appgateway01-sysdisk"
  description       = "Системный диск для Appgateway01"
  size              = var.ecs_disk_size
  volume_type       = "SSD" # Убедитесь, что тип диска поддерживается в вашем регионе
  availability_zone = data.sbercloud_availability_zones.az.names[0]
}

# Создание виртуальной машины Appgateway01
resource "sbercloud_compute_instance" "appgateway01" {
  name               = "${var.ecs_name}-appgateway01"
  flavor_id          = var.ecs_flavor
  image_id           = data.sbercloud_images_image.centos.id
  availability_zone  = data.sbercloud_availability_zones.az.names[0]
  admin_pass         = var.ecs_password
  security_group_ids = [sbercloud_networking_secgroup.secgroup.id]
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = <<-EOF
    #!/bin/bash
    echo "root:${var.ecs_password}" | chpasswd
    wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh
    chmod +x /tmp/init-backend.sh
    sh /tmp/init-backend.sh \
      ${sbercloud_compute_instance.appgateway02.access_ip_v4} \
      ${sbercloud_compute_instance.aass[0].access_ip_v4} \
      ${sbercloud_compute_instance.aass[1].access_ip_v4} \
      ${sbercloud_compute_instance.fleetmanager[0].access_ip_v4} \
      ${sbercloud_compute_instance.fleetmanager[1].access_ip_v4} \
      ${var.ecs_password} \
      ${sbercloud_lb_loadbalancer.elb_aass.vip_address} \
      ${data.sbercloud_rds_instances.rds_instance.instances[0].fixed_ip} \
      ${var.rds_password} \
      ${sbercloud_gaussdb_influx_instance.gaussdb_influx_instance.lb_ip_address} \
      ${var.influx_password} \
      ${sbercloud_dcs_instance.redis_instance.private_ip} \
      ${var.redis_password} \
      ${sbercloud_lb_loadbalancer.elb_appgateway.vip_address} \
      ${var.enterprise_project_id} \
      ${var.domain_id} \
      ${var.access_key} \
      ${var.secret_access_key} \
      ${sbercloud_obs_bucket.bucket.bucket} \
      ${sbercloud_vpc_eip.eip[0].address} \
      ${sbercloud_vpc_eip.eip[1].address} \
      ${sbercloud_vpc_eip.eip[2].address} \
      ${sbercloud_vpc_eip.eip[3].address} > /tmp/init_backend.log 2>&1
    rm -rf /tmp/init-backend.sh
    EOF
}

# Прикрепление системного диска к виртуальной машине Appgateway01
resource "sbercloud_compute_volume_attach" "appgateway01_sysdisk_attach" {
  instance_id = sbercloud_compute_instance.appgateway01.id
  volume_id   = sbercloud_evs_volume.appgateway01_sysdisk.id
}


# Appgateway02
resource "sbercloud_evs_volume" "appgateway02_system_disk" {
  name              = "${var.ecs_name}-appgateway02-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[1]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "appgateway02" {
  name              = "${var.ecs_name}-appgateway02"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[1]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}

resource "sbercloud_compute_volume_attachment" "appgateway02_attachment" {
  instance_id = sbercloud_compute_instance.appgateway02.id
  volume_id   = sbercloud_evs_volume.appgateway02_system_disk.id
}

# AASS Instances
resource "sbercloud_evs_volume" "aass_system_disks" {
  count             = 2
  name              = "${var.ecs_name}-aass0${count.index + 1}-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "aass" {
  count             = 2
  name              = "${var.ecs_name}-aass0${count.index + 1}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = filebase64("${path.module}/user_data/aass0${count.index + 1}.sh")
}

resource "sbercloud_compute_volume_attachment" "aass_attachments" {
  count       = 2
  instance_id = sbercloud_compute_instance.aass[count.index].id
  volume_id   = sbercloud_evs_volume.aass_system_disks[count.index].id
}

# Fleetmanager Instances
resource "sbercloud_evs_volume" "fleetmanager_system_disks" {
  count             = 2
  name              = "${var.ecs_name}-fleetmanager0${count.index + 1}-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "fleetmanager" {
  count             = 2
  name              = "${var.ecs_name}-fleetmanager0${count.index + 1}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = filebase64("${path.module}/user_data/fleetmanager0${count.index + 1}.sh")
}

resource "sbercloud_compute_volume_attachment" "fleetmanager_attachments" {
  count       = 2
  instance_id = sbercloud_compute_instance.fleetmanager[count.index].id
  volume_id   = sbercloud_evs_volume.fleetmanager_system_disks[count.index].id
}

# Console
resource "sbercloud_evs_volume" "console_system_disk" {
  name              = "${var.ecs_name}-console-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "console" {
  name              = "${var.ecs_name}-console"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = filebase64("${path.module}/user_data/console.sh")
}

resource "sbercloud_compute_volume_attachment" "console_attachment" {
  instance_id = sbercloud_compute_instance.console.id
  volume_id   = sbercloud_evs_volume.console_system_disk.id
}


terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = ">= 1.12.8"
    }
  }
}

provider "sbercloud" {
  auth_url       = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3"
  region         = "ru-moscow-1"
  access_key     = var.access_key
  secret_key     = var.secret_access_key
  security_token = var.security_token
}

output "GameFlexMatch_access_url" {
  description = "URL доступа к платформе GameFlexMatch"
  value       = <<EOF
  Из-за колебаний сети после успешного создания ресурсов подождите примерно 20 минут, затем в браузере введите http://${sbercloud_vpc_eip.eip[6].publicip[0].address} для доступа к платформе GameFlexMatch. Учётная запись администратора по умолчанию — admin, начальный пароль — пароль эластичной виртуальной машины; при первом входе система потребует сбросить пароль.
  EOF
}
