variable "charge_mode" {
  type        = string
  default     = "postPaid"
  description = "Режим оплаты; по умолчанию postPaid (оплата по факту). Опции: postPaid, prePaid (год/месяц)."
  nullable    = false

  validation {
    condition     = contains(["postPaid","prePaid"], var.charge_mode)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "charge_period_unit" {
  type        = string
  default     = "month"
  description = "Единица периода оплаты; действует только для prePaid. Опции: month (месяц), year (год)."
  nullable    = false

  validation {
    condition     = contains(["month","year"], var.charge_period_unit)
    error_message = "Invalid input. Please re-enter."
  }
}

variable "charge_period" {
  type        = number
  default     = 1
  description = "Период оплаты; действует только для prePaid. При month: 1–9; при year: 1–3. По умолчанию 1."
  nullable    = false

  validation {
    condition     = length(regexall("^[1-9]$", var.charge_period)) > 0
    error_message = "Invalid input. Please re-enter."
  }
}
