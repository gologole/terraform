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
}