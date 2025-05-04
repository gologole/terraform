terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "1.10.1"
    }
  }
}

provider "sbercloud" {
  auth_url       = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3"
  region         = "ru-moscow-1"
  access_key     = var.access_key
  secret_key     = var.secret_access_key
  security_token = var.security_token
}
