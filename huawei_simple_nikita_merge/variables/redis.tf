variable "redis_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Имя инстанса Redis в SberCloud DCS. Должно быть уникальным в рамках проекта, длина 4–64 символа, начинаться с буквы; допустимы цифры, буквы, подчёркивание (_) и дефис (-)."
  validation {
    condition     = length(regexall("^[a-zA-Z][\\w-]{3,63}$", var.redis_name)) > 0
    error_message = "redis_name должен начинаться с буквы и содержать 4–64 символа: буквы, цифры, подчёркивание или дефис."
  }
}

variable "redis_capacity" {
  type        = number
  default     = 2
  description = "Объём памяти для Redis (ГБ) в SberCloud DCS. Допустимые значения: 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 24, 32, 48, 64."
  validation {
    condition     = contains([0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 24, 32, 48, 64], var.redis_capacity)
    error_message = "redis_capacity должен быть одним из: 0.125, 0.25, 0.5, 1, 2, 4, 8, 16, 24, 32, 48 или 64."
  }
}

variable "redis_password" {
  type        = string
  default     = ""
  description = "Пароль для доступа к Redis в SberCloud DCS; длина 8–32 символа; должен содержать минимум три из четырёх типов символов: заглавные, строчные, цифры и специальные (~!@#%^*-_=+?)."
  sensitive   = true
  validation {
    condition     = (
      length(var.redis_password) >= 8 &&
      length(var.redis_password) <= 32 &&
      (
        can(regex("[A-Z]", var.redis_password)) +
        can(regex("[a-z]", var.redis_password)) +
        can(regex("[0-9]", var.redis_password)) +
        can(regex("[~!@#%^*\\-_=+?]", var.redis_password))
      ) >= 3
    )
    error_message = "redis_password должен быть 8–32 символа и содержать минимум три из: заглавных, строчных, цифр или спецсимволов ~!@#%^*-_=+?."
  }
}
