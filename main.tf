terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
    }
  }
}

provider "sbercloud" {
  enterprise_project_id = ${var.enterprise_project_id}
  insecure = true,
  auth_url = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3" 
  region   = "ru-moscow-1"

  access_key = var.access_key
  secret_key = var.secret_key
}
