variable "influx_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя инстанса GaussDB (InfluxDB) в SberCloud. Уникально в рамках проекта; длина 4–64 символа; начинается с буквы; допустимы цифры, буквы, подчёркивание (_) и дефис (-)."
  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.influx_name)) > 0
    error_message = "influx_name должен начинаться с буквы и содержать от 4 до 64 символов: буквы, цифры, '_' или '-'."
  }
}

variable "influx_flavor" {
  type        = string
  default     = "geminidb.influxdb.large.4"
  description = "Спецификация GaussDB (InfluxDB) в SberCloud. Допустимые значения: geminidb.influxdb.large.4, geminidb.influxdb.xlarge.4, geminidb.influxdb.2xlarge.4, geminidb.influxdb.4xlarge.4, geminidb.influxdb.8xlarge.4."
  validation {
    condition     = contains([
      "geminidb.influxdb.large.4",
      "geminidb.influxdb.xlarge.4",
      "geminidb.influxdb.2xlarge.4",
      "geminidb.influxdb.4xlarge.4",
      "geminidb.influxdb.8xlarge.4"
    ], var.influx_flavor)
    error_message = "influx_flavor должен быть одним из: geminidb.influxdb.large.4, geminidb.influxdb.xlarge.4, geminidb.influxdb.2xlarge.4, geminidb.influxdb.4xlarge.4 или geminidb.influxdb.8xlarge.4."
  }
}

variable "influx_volume_size" {
  type        = number
  default     = 100
  description = "Размер хранилища GaussDB (InfluxDB) в ГБ. Диапазон: 100–12000 ГБ, кратно 10."
  validation {
    condition     = var.influx_volume_size >= 100 && var.influx_volume_size <= 12000 && var.influx_volume_size % 10 == 0
    error_message = "influx_volume_size должен быть кратным 10 и находиться в диапазоне 100–12000 ГБ."
  }
}

variable "influx_password" {
  type        = string
  default     = ""
  description = "Пароль для инициализации GaussDB (InfluxDB) в SberCloud; длина 8–32 символа; минимум три типа из четырёх: заглавные, строчные, цифры и спецсимволы (~!@#$%^*-_=+?)."
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
