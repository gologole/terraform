variable "ecs_name" {
  type        = string
  default     = "gameflexmatch-hosting-platform-demo"
  description = "Префикс имени ECS; дублирование имён не допускается. Формат: {ecs_name}-appgateway0X, {ecs_name}-aass0X, {ecs_name}-fleetmanager0X и {ecs_name}-console, где X=1 или 2. Длина: 1–49 символов; поддерживаются цифры, буквы, подчёркивание (_), дефис (-) и точка (.). По умолчанию gameflexmatch-hosting-platform-demo."
  nullable    = false

  validation {
    condition     = length(regexall("^[\\w-\\.]{1,49}$", var.ecs_name)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_flavor" {
  type        = string
  default     = "c7.large.2"
  description = "Спецификация ECS; требуется минимум 2vCPU и 4GB. См. руководство по развертыванию. По умолчанию c7.large.2 (2vCPU, 4GB)."
  nullable    = false

  validation {
    condition     = length(regexall("^[a-z][a-z0-9]{0,3}\\.(x||[1-9][0-9]{0,1}x)large\\.[1-9][0-9]{0,1}$", var.ecs_flavor)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}

variable "ecs_password" {
  type        = string
  default     = ""
  description = "Пароль для инициализации ECS и платформы Console; после создания измените пароль в консоли ECS согласно руководству. Длина: 8–26 символов; минимум три типа из: заглавные, строчные, цифры, специальные (!@$%?*#.). Пароль не должен содержать имя пользователя или его обратную запись. Админ: root."
  nullable    = false
  sensitive   = true
}

variable "ecs_disk_size" {
  type        = number
  default     = 100
  description = "Размер системного диска ECS (SSD) в ГБ; диапазон: 40–1024; уменьшение не поддерживается. По умолчанию 100."
  nullable    = false

  validation {
    condition     = length(regexall("^([4-9]\\d|[1-9]\\d{2}|10[0-1][0-9]|102[0-4])$", var.ecs_disk_size)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}