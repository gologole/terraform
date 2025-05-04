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

