output "gameflexmatch_console_url" {
  description = "URL для доступа к консоли GameFlexMatch"
  value       = "http://${sbercloud_vpc_eip.eip[6].address}"
  sensitive   = false
}

output "gameflexmatch_setup_info" {
  description = "Информация о настройке платформы"
  value       = <<EOF
Информация для настройки GameFlexMatch:

Компоненты:
    - Appgateway1: ${sbercloud_vpc_eip.eip[0].address}
    - Appgateway2: ${sbercloud_vpc_eip.eip[1].address}
    - AASS1: ${sbercloud_vpc_eip.eip[2].address}
    - AASS2: ${sbercloud_vpc_eip.eip[3].address}
    - FleetManager1: ${sbercloud_vpc_eip.eip[4].address}
    - FleetManager2: ${sbercloud_vpc_eip.eip[5].address}
    - Console: ${sbercloud_vpc_eip.eip[6].address}

Балансировщики:
    - Appgateway: ${sbercloud_vpc_eip.eip[7].address}
    - FleetManager: ${sbercloud_vpc_eip.eip[8].address}

Базы данных:
    - MySQL: ${sbercloud_rds_instance.mysql.fixed_ip}
    - Redis: ${sbercloud_dcs_instance.redis.private_ip}

Пароли:
    - ECS: ${var.ecs_password}
    - MySQL: ${var.rds_password}
    - Redis: ${var.redis_password}
    - InfluxDB: ${var.influx_password}

Бакет:
    - OBS: ${sbercloud_obs_bucket.bucket.bucket}
EOF
  sensitive   = true
}
