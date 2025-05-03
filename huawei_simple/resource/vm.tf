# Виртуальные машины – Appgateway01
resource "huaweicloud_compute_instance" "appgateway1" {
  name                  = "${var.ecs_name}-appgateway01"                                     # Имя VM
  availability_zone     = data.huaweicloud_availability_zones.az.names[0]                    # Зона доступности
  image_id              = data.huaweicloud_images_image.centos.id                            # ID образа CentOS
  flavor_id             = var.ecs_flavor                                                      # Спецификация VM
  security_group_ids    = [huaweicloud_networking_secgroup.secgroup.id]                       # SG
  system_disk_type      = "GPSSD"                                                              # Тип системного диска
  system_disk_size      = var.ecs_disk_size                                                   # Размер диска (GB)
  admin_pass            = var.ecs_password                                                    # Пароль администратора
  delete_disks_on_termination = true                                                          # Удалять диск при удалении VM
  network {
    uuid = huaweicloud_vpc_subnet.subnet.id                                                  # Подсеть
  }
  scheduler_hints {
    group = huaweicloud_compute_servergroup.servergroup.id                                    # Группа размещения
  }
  agent_list            = "hss,ces"                                                           # Список агентов
  eip_id                = huaweicloud_vpc_eip.eip[0].id                                      # Подключённый EIP
  charging_mode         = var.charge_mode                                                     # Режим оплаты
  period_unit           = var.charge_period_unit                                              # Единица периода оплаты
  period                = var.charge_period                                                   # Период оплаты
  user_data             = <<-EOF                                                              # Скрипт инициализации
    #!/bin/bash
    echo "root:${var.ecs_password}" | chpasswd
    wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh
    chmod +x /tmp/init-backend.sh
    sh /tmp/init-backend.sh \
      ${huaweicloud_compute_instance.appgateway2.access_ip_v4} \
      ${huaweicloud_compute_instance.aass[0].access_ip_v4} \
      ${huaweicloud_compute_instance.aass[1].access_ip_v4} \
      ${huaweicloud_compute_instance.fleetmanager[0].access_ip_v4} \
      ${huaweicloud_compute_instance.fleetmanager[1].access_ip_v4} \
      ${var.ecs_password} \
      ${huaweicloud_lb_loadbalancer.elb_aass.vip_address} \
      ${data.huaweicloud_rds_instances.rds_instance.instances[0].fixed_ip} \
      ${var.rds_password} \
      ${huaweicloud_gaussdb_influx_instance.gaussdb_influx_instance.lb_ip_address} \
      ${var.influx_password} \
      ${huaweicloud_dcs_instance.redis_instance.private_ip} \
      ${var.redis_password} \
      ${huaweicloud_lb_loadbalancer.elb_appgateway.vip_address} \
      ${var.enterprise_project_id} \
      ${var.domain_id} \
      ${var.access_key} \
      ${var.secret_access_key} \
      ${huaweicloud_obs_bucket.bucket.bucket} \
      ${huaweicloud_vpc_eip.eip[0].address} \
      ${huaweicloud_vpc_eip.eip[1].address} \
      ${huaweicloud_vpc_eip.eip[2].address} \
      ${huaweicloud_vpc_eip.eip[3].address} > /tmp/init_backend.log 2>&1
    rm -rf /tmp/init-backend.sh
    EOF
}

# Виртуальная машина – Appgateway02
resource "huaweicloud_compute_instance" "appgateway2" {
  name                  = "${var.ecs_name}-appgateway02"
  availability_zone     = data.huaweicloud_availability_zones.az.names[1]
  image_id              = data.huaweicloud_images_image.centos.id
  flavor_id             = var.ecs_flavor
  security_group_ids    = [huaweicloud_networking_secgroup.secgroup.id]
  system_disk_type      = "GPSSD"
  system_disk_size      = var.ecs_disk_size
  admin_pass            = var.ecs_password
  delete_disks_on_termination = true
  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  eip_id                = huaweicloud_vpc_eip.eip[1].id
  scheduler_hints {
    group = huaweicloud_compute_servergroup.servergroup.id
  }
  agent_list            = "hss,ces"
  charging_mode         = var.charge_mode
  period_unit           = var.charge_period_unit
  period                = var.charge_period
}

# Виртуальные машины – AASS (2 экземпляра)
resource "huaweicloud_compute_instance" "aass" {
  count                 = 2
  name                  = "${var.ecs_name}-aass0${count.index + 1}"   # aass01, aass02
  availability_zone     = local.az[count.index % 2]                  # Попеременно по зонам
  image_id              = data.huaweicloud_images_image.centos.id
  flavor_id             = var.ecs_flavor
  security_group_ids    = [huaweicloud_networking_secgroup.secgroup.id]
  system_disk_type      = "GPSSD"
  system_disk_size      = var.ecs_disk_size
  admin_pass            = var.ecs_password
  delete_disks_on_termination = true
  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  scheduler_hints {
    group = huaweicloud_compute_servergroup.servergroup.id
  }
  eip_id                = huaweicloud_vpc_eip.eip[count.index + 2].id # EIP[2] и EIP[3]
  agent_list            = "hss,ces"
  charging_mode         = var.charge_mode
  period_unit           = var.charge_period_unit
  period                = var.charge_period
}

# Виртуальные машины – Fleetmanager (2 экземпляра)
resource "huaweicloud_compute_instance" "fleetmanager" {
  count                 = 2
  name                  = "${var.ecs_name}-fleetmanager0${count.index + 1}"
  availability_zone     = local.az[count.index % 2]
  image_id              = data.huaweicloud_images_image.centos.id
  flavor_id             = var.ecs_flavor
  security_group_ids    = [huaweicloud_networking_secgroup.secgroup.id]
  system_disk_type      = "GPSSD"
  system_disk_size      = var.ecs_disk_size
  admin_pass            = var.ecs_password
  delete_disks_on_termination = true
  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  scheduler_hints {
    group = huaweicloud_compute_servergroup.servergroup.id
  }
  eip_id                = huaweicloud_vpc_eip.eip[count.index + 4].id # EIP[4] и EIP[5]
  agent_list            = "hss,ces"
  charging_mode         = var.charge_mode
  period_unit           = var.charge_period_unit
  period                = var.charge_period
}

# Консольная VM – Console
resource "huaweicloud_compute_instance" "console" {
  depends_on            = [huaweicloud_compute_instance.appgateway1]
  name                  = "${var.ecs_name}-console"
  availability_zone     = data.huaweicloud_availability_zones.az.names[0]
  image_id              = data.huaweicloud_images_image.centos.id
  flavor_id             = var.ecs_flavor
  security_group_ids    = [huaweicloud_networking_secgroup.secgroup.id]
  system_disk_type      = "GPSSD"
  system_disk_size      = var.ecs_disk_size
  admin_pass            = var.ecs_password
  delete_disks_on_termination = true
  network {
    uuid = huaweicloud_vpc_subnet.subnet.id
  }
  agent_list            = "hss,ces"
  eip_id                = huaweicloud_vpc_eip.eip[6].id
  charging_mode         = var.charge_mode
  period_unit           = var.charge_period_unit
  period                = var.charge_period
  user_data             = <<-EOF
    #!/bin/bash
    echo "root:${var.ecs_password}" | chpasswd
    wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-console.sh
    chmod +x /tmp/init-console.sh
    sh /tmp/init-console.sh \
      ${huaweicloud_compute_instance.appgateway1.access_ip_v4} \
      ${var.ecs_password} \
      ${huaweicloud_lb_loadbalancer.elb_fleetmanager.vip_address} > /tmp/init-console.log 2>&1
    rm -rf /tmp/init-console.sh
    EOF
}