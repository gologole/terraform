variable "enterprise_project_id" {
  default     = "0"
  description = "企业项目id，请参考部署指南到项目管理界面获取https://console.huaweicloud.com/eps/，0代表default项目。默认为0。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}$|^0$", var.enterprise_project_id))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "vpc_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "虚拟私有云 VPC名称，该模板新建VPC，不允许重名。取值范围：1-54个字符，支持数字、字母、中文、_（下划线）、-（中划线）、.（点）。默认为gameflexmatch-hosting-platform-demo"
  type        = string
  nullable    = false
}

variable "security_group_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "安全组名称，该模板新建安全组，安全组规则请参考部署指南进行配置。取值范围：1-64个字符，支持数字、字母、中文、_（下划线）、-（中划线）、.（点）。默认为gameflexmatch-hosting-platform-demo"
  type        = string
  nullable    = false
}

variable "eip_bandwidth_size" {
  default     = 5
  description = "弹性公网IP EIP带宽大小，单位：Mbit/s，计费方式为按带宽计费。取值范围：1-2,000。默认5。"
  type        = number
  nullable    = false

  validation {
    condition     = can(regex("^([1-9]|[1-9]\\d{1,2}|1\\d{3}|2000)$", tostring(var.eip_bandwidth_size)))
    error_message = "Invalid input, please re-enter."
  }
}

variable "obs_bucket_name" {
  default     = ""
  description = "对象存储服务 OBS桶名称前缀，命名方式：{obs_bucket_name}-obs，用于存放应用数据，不允许重名。取值范围：1-59个字符，以字母或数字开头、结尾，仅支持小写字母、数字、中划线（-）、英文句号（.）。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\.-]{0,57}[a-z0-9]$", var.obs_bucket_name))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_name" {
  default     = "gameflexmatch-hosting-platform-demo"
  description = "弹性云服务器 ECS名称前缀，不允许重名。命名规则{ecs_name}-appgateway0X、{ecs_name}-aass0X、{ecs_name}-fleetmanager0X及{ecs_name}-console，其中X取值[1,2]。取值范围：1-49个字符，支持数字、字母、_（下划线）、-（中划线）、.（点）。默认为gameflexmatch-hosting-platform-demo"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[\\w-\\.]{1,49}$", var.ecs_name))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_flavor" {
  default     = "c7.large.2"
  description = "ECS规格，请使用2vCPUs4GB及以上规格，请参考部署指南配置。默认c7.large.2（c7|2vCPUs|4GB）。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,3}\\.(x|[1-9][0-9]{0,1}x)large\\.[1-9][0-9]{0,1}$", var.ecs_flavor))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_password" {
  default     = ""
  description = "ECS初始化密码及Console运维平台初始化密码，创建完成后，请参考部署指南登录ECS控制台修改密码。取值范围：长度为8-26位，密码至少必须包含大写字母、小写字母、数字和特殊字符（!@$%?*#.）中的三种，密码不能包含用户名或用户名的逆序。管理员帐户为root。"
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
  description = "云数据库RDS for MySQL名称，不支持重名。取值范围：4-64个字符，以字母开头，支持数字、字母、_（下划线）、-（中划线）。默认：gameflexmatch-hosting-platform-demo。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z][\\w-]{3,63}$", var.rds_name))
    error_message = "Invalid input. Please re-enter."
  }
}

variable "rds_flavor" {
  default     = "rds.mysql.n1.large.2.ha"
  description = "云数据库RDS规格，详细规格信息请参考https://support.huaweicloud.com/productdesc-rds/rds_01_0034.html。默认：rds.mysql.n1.large.2.ha（通用型主备实例2vCPU4GB）。"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^(rds.mysql.)(n1.|x1.)(x|2x|4x|8x|16x||)large.((2|4|8).ha|(2|4|8))$", var.rds_flavor))
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
  default     = ""
  description = "云数据库RDS for MySQL  root用户登录密码，默认为3个服务组件分别创建三个数据库appgateway/aass/fleetmanager及同名数据库登录用户，初始密码为该密码。取值范围：8-32个字符，必须至少包含大写字母、小写字母、数字和特殊字符（~!@#$%^*-_=+?,()&）中的三种。"
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
  description = "分布式缓存服务 Redis版主备实例缓存内存规格，以GB为单位，具体规格详见：https://support.huaweicloud.com/productdesc-dcs/dcs-pd-0522002.html。默认2。"
  type        = number
  nullable    = false

  validation {
    condition     = contains([0.125,0.25,0.5,1,2,4,8,16,24,32,48,64], var.redis_capacity)
    error_message = "Invalid input, please re-enter."
  }
}

variable "redis_password" {
  default     = ""
  description = "分布式缓存服务 Redis版实例初始化密码，取值范围：长度为8-32个字符，必须至少包含大写字母、小写字母、数字、特殊字符~!@#%^*-_=+?中的三种。"
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
  default     = ""
  description = "账号访问密钥（AK），识别访问用户的身份。用于资源创建及上传镜像环境配置文件至OBS桶及GameFlexMatch的管理面服务组件的管理与执行，请参考部署指南获取。取值范围：20个字符，仅支持大写字母和数字。"
  type        = string
  nullable    = false
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Z0-9]{20}$", var.access_key))
    error_message = "Invalid input, please re-enter."
  }
}

variable "secret_access_key" {
  default     = ""
  description = "账号秘密访问密钥（SK），对请求数据进行签名验证。用于资源创建上传镜像环境配置文件至OBS桶及GameFlexMatch的管理面服务组件的管理与执行，请参考部署指南获取。取值范围：40个字符，仅支持大小写字母和数字。"
  type        = string
  nullable    = false
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9]{40}$", var.secret_access_key))
    error_message = "Invalid input, please re-enter."
  }
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