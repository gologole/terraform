variable "enterprise_project_id" {
  default     = "0"
  description = "ID корпоративного проекта"
  type        = string
  nullable    = false
  validation {
    condition     = length(regexall("^[a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}$|^0$", var.enterprise_project_id)) > 0
    error_message = "Некорректный формат ID проекта."
  }
}

variable "vpc_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя VPC"
  type        = string
  nullable    = false
}

variable "security_group_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя группы безопасности"
  type        = string
  nullable    = false
}

variable "eip_bandwidth_size" {
  default     = 5
  description = "Размер полосы пропускания EIP в Мбит/с"
  type        = number
  nullable    = false
  validation {
    condition     = length(regexall("^([1-9]|[1-9]\\d{1,2}|1\\d{3}|2000)$", var.eip_bandwidth_size)) > 0
    error_message = "Некорректное значение полосы пропускания."
  }
}

variable "obs_bucket_name" {
  default     = ""
  description = "Префикс имени бакета OBS"
  type        = string
  nullable    = false
  validation {
    condition     = length(regexall("^[a-z0-9][a-z0-9\\.-]{0,57}[a-z0-9]$", var.obs_bucket_name)) > 0
    error_message = "Некорректное имя бакета."
  }
}

variable "ecs_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс имени ECS"
  type        = string
  nullable    = false
  validation {
    condition     = length(regexall("^[\\w-\\.]{1,49}$", var.ecs_name)) > 0
    error_message = "Некорректное имя ECS."
  }
}

variable "ecs_flavor" {
  default     = "s6.large.2"  # Изменено для SberCloud
  description = "Тип инстанса ECS"
  type        = string
  nullable    = false
}

variable "ecs_password" {
  description = "Пароль для ECS"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "ecs_disk_size" {
  default     = 100
  description = "ECS系统盘大小，磁盘类型默认通用型SSD，以GB为单位，取值范围为40-1,024，不支持缩盘。默认为100。"
  type        = number
  nullable    = false

  validation {
    condition     = can(regex("^([4-9]\\d|[1-9]\\d{2}|10[0-1][0-9]|102[0-4])$", tostring(var.ecs_disk_size)))
    error_message = "Invalid input, please re-enter."
  }
}

variable "rds_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя RDS инстанса"
  type        = string
  nullable    = false
}

variable "rds_flavor" {
  default     = "rds.mysql.s1.large.ha"
  description = "Тип инстанса RDS"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^rds\\.mysql\\.(s1|n1|x1)\\.(large|xlarge|2xlarge|4xlarge|8xlarge|16xlarge)(\\.ha)?$", var.rds_flavor))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_volume_size" {
  default     = 100
  description = "云数据库RDS实例存储空间大小，默认存储盘类型为SSD云盘，取值范围：40-4,000，必须为10的整数倍。默认100GB。"
  type        = number
  nullable    = false

  validation {
    condition     = can(regex("^([4-9]0|[1-9][0-9]0|[1-3][0-9]{2}0|4000)$", tostring(var.rds_volume_size)))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_password" {
  description = "Пароль для RDS"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "influx_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "云数据库GaussDB(for InfluxDB)实例名称，取值范围：4-64个字符，以字母开头，支持数字、字母、_（下划线）、-（中划线）。默认为gameflexmatch-hosting-platform-demo。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z][\\w-]{3,63}$", var.influx_name))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "influx_flavor" {
  default     = "geminidb.influxdb.large.4"
  description = "云数据库GaussDB(for InfluxDB)实例规格，规格信息请参考https://support.huaweicloud.com/influxug-nosql/nosql_05_0045.html。默认为geminidb.influxdb.large.4（2vCPUs|8GB）。"
  type        = string
  nullable    = false

  validation {
    condition     = contains(["geminidb.influxdb.large.4","geminidb.influxdb.xlarge.4","geminidb.influxdb.2xlarge.4","geminidb.influxdb.4xlarge.4","geminidb.influxdb.8xlarge.4"], var.influx_flavor)
    error_message = "Invalid input, please re-enter."
  }
}

variable "influx_volume_size" {
  default     = 100
  description = "云数据库GaussDB(for InfluxDB)实例存储空间大小，以GB为单位，取值范围：100-12,000。默认100。"
  type        = number
  nullable    = false

  validation {
    condition     = can(regex("^([1-9][0-9]{2,3}|1[0-1][0-9]{3}|12000)$", tostring(var.influx_volume_size)))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "influx_password" {
  default     = ""
  description = "云数据库GaussDB(for InfluxDB)实例初始化密码，取值范围：长度为8-32个字符，必须是大写字母、小写字母、数字、特殊字符~!@#%^*-_=+?的组合。管理员账户名默认为rwuser。"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "redis_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "分布式缓存服务 Redis版实例名称，取值范围：4-64个字符，以字母开头，支持数字、字母、_（下划线）、-（中划线）。默认gameflexmatch-hosting-platform-demo。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z][\\w-]{3,63}$", var.redis_name))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "redis_capacity" {
  default     = 2
  description = "Размер Redis кластера в GB"
  type        = number
  nullable    = false
}

variable "redis_password" {
  description = "Пароль для Redis"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "elb_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "弹性负载均衡 ELB名称前缀，命名规则{elb_name}_appgateway、{elb_name}_aass、{elb_name}_fleetmanager。取值范围：1-51个字符组成，支持中文、英文字母、数字、_（下划线）、-（中划线）、.（点）。默认gameflexmatch-hosting-platform-demo。"
  type        = string
  nullable    = false
}

variable "domain_id" {
  default     = ""
  description = "账户ID，请参考部署指南获取。取值范围：32位，仅支持小写字母和数字。"
  type        = string
  nullable    = false
  sensitive   = true

  validation {
    condition     = can(regex("^[a-z0-9]{32}$", var.domain_id))
    error_message = "Invalid input, please re-enter."
  }
}

variable "access_key" {
  description = "Access key для аутентификации в SberCloud"
  type        = string
  sensitive   = true
}

variable "secret_access_key" {
  description = "Secret key для аутентификации в SberCloud"
  type        = string
  sensitive   = true
}

variable "iam_agency_name" {
  default     = ""
  description = "IAM委托名，不能重名，用于打包镜像时安装ICAgent以及使用LTS云日志服务的日志转储。取值范围：长度1-59个字符，支持字母、数字、空格及特殊字符-_.,。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[\\w\\s-\\.,]{1,59}$", var.iam_agency_name))
    error_message = "Invalid input, please re-enter."
  }
}

variable "charge_mode" {
  default     = "postPaid"
  description = "计费模式，默认自动扣费，可选值为：postPaid（按需计费）、prePaid（包年包月）。默认postPaid。"
  type        = string
  nullable    = false

  validation {
    condition     = contains(["postPaid", "prePaid"], var.charge_mode)
    error_message = "Invalid input, please re-enter."
  }
}

variable "charge_period_unit" {
  default     = "month"
  description = "订购周期类型，仅当charge_mode为prePaid（包年/包月）生效。取值范围：month（月），year（年）。默认month。"
  type        = string
  nullable    = false

  validation {
    condition     = contains(["month", "year"], var.charge_period_unit)
    error_message = "Invalid input, please re-enter."
  }
}

variable "charge_period" {
  default     = 1
  description = "订购周期，仅当charge_mode为prePaid（包年/包月）生效。取值范围：charge_period_unit=month（周期类型为月）时，取值为1-9；charge_period_unit=year（周期类型为年）时，取值为1-3。默认订购1月。"
  type        = number
  nullable    = false

  validation {
    condition     = can(regex("^[1-9]$", tostring(var.charge_period)))
    error_message = "Invalid input, please re-enter."
  }
}

variable "backend_script_url" {
  description = "URL скрипта для установки и настройки бэкенда"
  type        = string
  default     = "https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh"
}

variable "console_script_url" {
  description = "URL скрипта для установки и настройки консоли"
  type        = string
  default     = "https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-console.sh"
}

variable "influxdb_script_url" {
  description = "URL скрипта установки InfluxDB"
  type        = string
  default     = "https://raw.githubusercontent.com/gologole/terraform/main/scripts/init-influxdb.sh"
}

variable "availability_zone" {
  description = "Зона доступности в регионе ru-moscow-1"
  type        = string
  default     = "ru-moscow-1a"
}

variable "project_name" {
  description = "Имя проекта, используется как префикс для ресурсов"
  type        = string
  default     = "gameflexmatch"
}

variable "security_token" {
  description = "Security Token (STS) для аутентификации в SberCloud"
  type        = string
  sensitive   = true
}

variable "account_name" {
  description = "Имя аккаунта в SberCloud"
  type        = string
}