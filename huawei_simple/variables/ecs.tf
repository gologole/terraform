variable "ecs_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс имени ECS в SberCloud; формат: {prefix}-appgateway0X, {prefix}-aass0X, {prefix}-fleetmanager0X и {prefix}-console, где X = 1 или 2. Длина 1–49 символов; допустимы буквы, цифры, '_', '-' и '.'."
  validation {
    condition     = length(regexall("^[\\w-.]{1,49}$", var.ecs_name)) > 0
    error_message = "ecs_name должен содержать 1–49 символов: буквы, цифры, '_', '-' или '.'."
  }
}

variable "ecs_flavor" {
  type        = string
  default     = "c7.large.2"
  description = "Название flavor для ECS в SberCloud (минимум 2 vCPU и 4 GB). Список доступных можно посмотреть в настройках AS configuration or EVS volume resources провайдера. По умолчанию c7.large.2."
  validation {
    condition = length(regexall("^[a-z][a-z0-9]{0,3}\\.(x[1-9]|[1-9][0-9]x?)large\\.[1-9][0-9]?$", var.ecs_flavor)) > 0
    error_message = "ecs_flavor должен соответствовать шаблону типа c{generation}.{size}.X (например, c7.large.2)."
  }
}

variable "ecs_password" {
  type        = string
  default     = ""
  description = "Пароль для root в ECS и Console SberCloud; длина 8–26 символов; минимум три из четырёх групп: заглавные, строчные, цифры, спецсимволы (!@$%?*#.). Пароль не должен содержать имя пользователя или обратную запись."
  sensitive   = true
  validation {
    condition = (
      length(var.ecs_password) >= 8 &&
      length(var.ecs_password) <= 26 &&
      (
        can(regex("[A-Z]", var.ecs_password)) +
        can(regex("[a-z]", var.ecs_password)) +
        can(regex("[0-9]", var.ecs_password)) +
        can(regex("[!@\\$%\\?\\*#\\.]", var.ecs_password))
      ) >= 3
    )
    error_message = "ecs_password должен быть 8–26 символов и содержать не менее трёх типов символов: заглавные, строчные, цифры или спецсимволы (!@$%?*#.)."
  }
}

variable "ecs_disk_size" {
  type        = number
  default     = 100
  description = "Размер системного EVS-диска (SSD) для ECS в ГБ; диапазон: 40–1024 ГБ, шаг — 10 ГБ. Уменьшение размера после создания не поддерживается."
  validation {
    condition     = var.ecs_disk_size >= 40 && var.ecs_disk_size <= 1024 && var.ecs_disk_size % 10 == 0
    error_message = "ecs_disk_size должен быть числом от 40 до 1024, кратным 10."
  }
}
