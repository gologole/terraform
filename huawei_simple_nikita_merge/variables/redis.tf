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
