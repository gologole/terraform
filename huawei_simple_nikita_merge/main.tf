terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "~> 1.12.9"
    }
  }
}

provider "sbercloud" {
  # URL для IAM в вашем регионе
  auth_url              = var.sbercloud_auth_url
  # Регион SberCloud (например, ru-moscow-1)
  region                = var.region
  # Данные AK/SK для аутентификации
  access_key            = var.access_key
  secret_key            = var.secret_key
  # Опциональный Enterprise Project ID
  enterprise_project_id = var.enterprise_project_id
  # Разрешить небезопасные TLS-соединения (если нужно)
  insecure              = var.insecure
}
