terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "~> 1.10.0"
    }
  }
}

provider "sbercloud" {
  enterprise_project_id = var.enterprise_project_id
  auth_url             = "https://iam.ru-moscow-1.hc.sbercloud.ru/v3"
  region               = "ru-moscow-1"
  access_key           = var.access_key
  secret_key           = var.secret_access_key
}

# Получаем список доступных зон
data "sbercloud_availability_zones" "az" {}

# Получаем образ CentOS
data "sbercloud_images_image" "centos" {
  name        = "CentOS 7.9 64bit"  # Вот это надо уточнить
  visibility  = "public"
  most_recent = true
}

# Получаем информацию о Redis
data "sbercloud_dcs_flavors" "dcs_flavors" {
  engine_version = "5.0"
  cache_mode     = "ha"
  capacity       = var.redis_capacity
}

# Получаем информацию о RDS инстансах
data "sbercloud_rds_instances" "rds_instance" {
  depends_on = [
    sbercloud_rds_instance.rds_single_instance,
    sbercloud_rds_instance.rds_ha_instance
  ]
  
  name           = var.rds_name
  datastore_type = "MySQL"
  vpc_id         = sbercloud_vpc_subnet.subnet.vpc_id
  subnet_id      = sbercloud_vpc_subnet.subnet.id
}

# Вот это надо поменять
locals {
  az = [
    data.sbercloud_availability_zones.az.names[0],
    data.sbercloud_availability_zones.az.names[1]
  ]
}