terraform {
  required_providers {
    huaweicloud = {
      source  = "huawei.com/provider/huaweicloud"
      version = "1.50.0"
    }
  }
}

provider "huaweicloud" {
  cloud                  = "myhuaweicloud.com" # Облако Huawei
  endpoints = {
    iam = "iam.cn-north-4.myhuaweicloud.com"  # Конечная точка IAM
    dns = "dns.cn-north-4.myhuaweicloud.com"  # Конечная точка DNS
  }
  enterprise_project_id = var.enterprise_project_id # ID корпоративного проекта
  insecure              = true                      # Разрешить небезопасные соединения
  region                = "cn-north-4"              # Регион
  auth_url              = "https://iam.cn-north-4.myhuaweicloud.com/v3" # URL аутентификации
}
