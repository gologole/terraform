variable "enterprise_project_id" {
  type        = string
  description = "SberCloud Enterprise Project ID (опционально). Если не задано, берётся из provider-level или SBC_ENTERPRISE_PROJECT_ID."
  default     = null
}

variable "vpc_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя SberCloud VPC. Уникально в проекте. Длина 1–54 символа; поддерживаются китайские символы, латиница, цифры, _, - и .."
}

variable "security_group_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя группы безопасности в SberCloud. Длина 1–64 символа; поддерживаются китайские символы, латиница, цифры, _, - и .."
}

variable "eip_bandwidth_size" {
  type        = number
  default     = 5
  description = "Ширина полосы пропускания EIP в Мбит/с (pay-per-bandwidth). Диапазон: 1–2000."
  validation {
    condition     = var.eip_bandwidth_size >= 1 && var.eip_bandwidth_size <= 2000
    error_message = "eip_bandwidth_size должна быть между 1 и 2000."
  }
}

variable "obs_bucket_name" {
  type        = string
  default     = ""
  description = "Префикс для OBS‑бакета; итоговый bucket будет \"{prefix}-obs\". Длина 1–59 символов; строчные буквы, цифры, - и .; должно начинаться и заканчиваться буквой или цифрой."
  validation {
    condition     = var.obs_bucket_name == "" || length(regexall("^[a-z0-9][a-z0-9\\.-]{0,57}[a-z0-9]$", var.obs_bucket_name)) > 0
    error_message = "obs_bucket_name должен соответствовать ^[a-z0-9][a-z0-9\\.-]{0,57}[a-z0-9]$."
  }
}

variable "elb_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс для ELB; используются имена \"{prefix}_appgateway\", \"{prefix}_aass\", \"{prefix}_fleetmanager\". Длина 1–51 символ; поддерживаются китайские символы, латиница, цифры, _, - и .."
}

variable "domain_id" {
  type        = string
  default     = ""
  description = "Domain ID учётной записи SberCloud. 32 строчные латинские буквы и цифры."
  sensitive   = true
  validation {
    condition     = var.domain_id == "" || length(regexall("^[a-z0-9]{32}$", var.domain_id)) > 0
    error_message = "domain_id должен быть 32 символа: [a-z0-9]."
  }
}

variable "access_key" {
  type        = string
  default     = ""
  description = "SberCloud Access Key (AK) для API. 20 заглавных букв и цифр."
  sensitive   = true
  validation {
    condition     = var.access_key == "" || length(regexall("^[A-Z0-9]{20}$", var.access_key)) > 0
    error_message = "access_key должен быть 20 символов: [A-Z0-9]."
  }
}

variable "secret_access_key" {
  type        = string
  default     = ""
  description = "SberCloud Secret Key (SK) для API. 40 букв и цифр."
  sensitive   = true
  validation {
    condition     = var.secret_access_key == "" || length(regexall("^[A-Za-z0-9]{40}$", var.secret_access_key)) > 0
    error_message = "secret_access_key должен быть 40 символов: [A-Za-z0-9]."
  }
}

variable "iam_agency_name" {
  type        = string
  default     = ""
  description = "Имя доверенного агентства IAM. Для установки ICAgent и экспорта в LTS. Длина 1–59 символов; буквы, цифры, пробелы, символы - _ . ,."
  validation {
    condition     = var.iam_agency_name == "" || length(regexall("^[\\w\\s-\\.,]{1,59}$", var.iam_agency_name)) > 0
    error_message = "iam_agency_name должен быть 1–59 символов: [\\w\\s-\\.,]."
  }
}
