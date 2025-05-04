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
    condition     = contains(["postPaid","prePaid"], var.charge_mode)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "charge_period_unit" {
  type        = string
  default     = "month"
  description = "Единица периода оплаты; действует только для prePaid. Опции: month (месяц), year (год)."
  nullable    = false

  validation {
    condition     = contains(["month","year"], var.charge_period_unit)
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
    condition = length(regexall("^[a-z][a-z0-9]{0,3}\\.(x[1-9]|[1-9][0-9]x?)large\\.[1-9][0-9]?$", var.ecs_flavor)) > 0
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
      length(var.ecs_password) <= 26 &&
      (
        can(regex("[A-Z]", var.ecs_password)) +
        can(regex("[a-z]", var.ecs_password)) +
        can(regex("[0-9]", var.ecs_password)) +
        can(regex("[!@\\$%\\?\\*#\\.]", var.ecs_password))
      ) >= 3
    )
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
    condition     = contains([
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
      length(var.influx_password) <= 32 &&
      (
        can(regex("[A-Z]", var.influx_password)) +
        can(regex("[a-z]", var.influx_password)) +
        can(regex("[0-9]", var.influx_password)) +
        can(regex("[~!@#$%^*\\-_=+?]", var.influx_password))
      ) >= 3
    )
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
    condition     = contains([0.125,0.25,0.5,1,2,4,8,16,24,32,48,64], var.redis_capacity)
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


terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "1.10.1"
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
