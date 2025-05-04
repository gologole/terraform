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