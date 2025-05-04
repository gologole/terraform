variable "rds_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя инстанса RDS for MySQL в SberCloud. Уникально в рамках проекта; длина 4–64 символа; начинается с буквы; допустимы буквы, цифры, подчёркивание (_) и дефис (-)."

  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.rds_name)) > 0
    error_message = "rds_name должен начинаться с буквы и содержать от 4 до 64 символов: буквы, цифры, '_' или '-'."
  }
}

variable "rds_flavor" {
  type        = string
  default     = "rds.mysql.n1.large.2.ha"
  description = "Спецификация RDS for MySQL в SberCloud. Смотрите список доступных конфигураций в консоли SberCloud или в Terraform Registry."

  validation {
    condition     = length(regexall("^rds\\.mysql\\.(n[1-9]|x[1-9])\\.large\\.(2|4|8)(\\.ha)?$", var.rds_flavor)) > 0
    error_message = "rds_flavor должен соответствовать шаблону rds.mysql.{n1|…|n9|x1|…|x9}.large.{2|4|8}[.ha]."
  }
}

variable "rds_volume_size" {
  type        = number
  default     = 100
  description = "Размер тома RDS (SSD) в ГБ. Диапазон 40–4000 ГБ, шаг — 10 ГБ."

  validation {
    condition     = var.rds_volume_size >= 40 &&
                    var.rds_volume_size <= 4000 &&
                    var.rds_volume_size % 10 == 0
    error_message = "rds_volume_size должен быть кратен 10 и находиться в диапазоне 40–4000 ГБ."
  }
}

variable "rds_password" {
  type        = string
  default     = ""
  description = "Пароль root для RDS for MySQL в SberCloud. Длина 8–32 символа; минимум три из четырёх групп: заглавные, строчные, цифры, спецсимволы (~!@#$%^*-_=+?,()&)."
  sensitive   = true

  validation {
    condition = (
      length(var.rds_password) >= 8 &&
      length(var.rds_password) <= 32 &&
      (
        can(regex("[A-Z]", var.rds_password)) +
        can(regex("[a-z]", var.rds_password)) +
        can(regex("[0-9]", var.rds_password)) +
        can(regex("[~!@#$%^*\\-_=+?,()&]", var.rds_password))
      ) >= 3
    )
    error_message = "rds_password должен быть 8–32 символа и содержать не менее трёх типов: заглавные, строчные, цифры или спецсимволы."
  }
}
