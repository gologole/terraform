output "gameflexmatch_console_url" {
  description = "URL для доступа к консоли GameFlexMatch"
  value       = "http://${sbercloud_vpc_eip.eip[6].address}"
  sensitive   = false
}

output "gameflexmatch_setup_info" {
  description = "Информация о настройке платформы"
  value       = <<-EOT
    После успешного создания ресурсов подождите примерно 20 минут для полной инициализации системы.
    
    Доступ к консоли GameFlexMatch:
    URL: http://${sbercloud_vpc_eip.eip[6].address}
    Логин: admin
    Пароль: ${var.ecs_password} (рекомендуется сменить при первом входе)
    
    Важные IP-адреса:
    - Appgateway ELB: ${sbercloud_vpc_eip.eip[7].address}
    - FleetManager ELB: ${sbercloud_vpc_eip.eip[8].address}
    
    База данных MySQL:
    - Хост: ${sbercloud_rds_instance.mysql.fixed_ip}
    - Порт: 3306
    
    Redis:
    - Хост: ${sbercloud_dcs_instance.redis.ip}
    - Порт: 6379
  EOT
  sensitive   = true
}
