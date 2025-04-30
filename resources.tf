# VPC и подсеть
resource "sbercloud_vpc" "vpc" {
  name = var.vpc_name
  cidr = "192.168.0.0/16"
}

resource "sbercloud_vpc_subnet" "subnet" {
  name          = "${var.vpc_name}-subnet"
  cidr          = "192.168.1.0/24"
  gateway_ip    = "192.168.1.1"
  vpc_id        = sbercloud_vpc.vpc.id
  primary_dns   = "100.125.13.59"
  secondary_dns = "8.8.8.8"
}

# Группа IP-адресов
resource "sbercloud_vpc_address_group" "ipgroup" {
  name        = "GameFlexMatch_ipGroup"
  description = "Группа IP-адресов для взаимодействия Appgateway и Auxproxy"
  addresses   = [
    sbercloud_vpc_eip.eip[0].address,
    sbercloud_vpc_eip.eip[1].address,
    sbercloud_vpc_eip.eip[7].address
  ]
}

# Группа безопасности
resource "sbercloud_networking_secgroup" "secgroup" {
  name        = var.security_group_name
  description = "Security group for GameFlexMatch platform"
}

# Правила группы безопасности
resource "sbercloud_networking_secgroup_rule" "allow_ping" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_ssh" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 22
  port_range_max   = 22
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_mysql" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 3306
  port_range_max   = 3306
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_appgateway" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 60003
  port_range_max   = 60003
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_component_mutual_access" {
  direction                = "ingress"
  ethertype               = "IPv4"
  protocol                = "tcp"
  port_range_min          = 60003
  port_range_max          = 60003
  remote_address_group_id = sbercloud_vpc_address_group.ipgroup.id
  security_group_id       = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_aass" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 9091
  port_range_max   = 9091
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_fleetmanager" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 31002
  port_range_max   = 31002
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_redis" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 6379
  port_range_max   = 6379
  remote_ip_prefix = sbercloud_vpc_subnet.subnet.cidr
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_console" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 80
  port_range_max   = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

# EIP ресурсы
resource "sbercloud_vpc_eip" "eip" {
  count = 9
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.vpc_name}-bandwidth-${count.index}"
    size        = var.eip_bandwidth_size
    share_type  = "PER"
    charge_mode = "bandwidth"
  }
}

# Группа серверов с anti-affinity
resource "sbercloud_compute_servergroup" "servergroup" {
  name     = "${var.ecs_name}-servergroup"
  policies = ["anti-affinity"]
}

# OBS бакет
resource "sbercloud_obs_bucket" "bucket" {
  bucket        = "${var.obs_bucket_name}-obs"
  acl           = "private"
  force_destroy = true
}

# ECS инстансы
resource "sbercloud_compute_instance" "appgateway1" {
  name              = "${var.ecs_name}-appgateway01"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  security_groups   = [sbercloud_networking_secgroup.secgroup.name]
  availability_zone = local.az[0]
  admin_pass        = var.ecs_password

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  system_disk_type = "SSD"
  system_disk_size = var.ecs_disk_size

  scheduler_hints {
    group = sbercloud_compute_servergroup.servergroup.id
  }

  user_data = base64encode(
    <<-EOF
      #!/bin/bash
      echo 'root:${var.ecs_password}' | chpasswd
      wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh
      chmod +x /tmp/init-backend.sh
      sh /tmp/init-backend.sh ${sbercloud_compute_instance.appgateway2.access_ip_v4} ${sbercloud_compute_instance.aass[0].access_ip_v4} ${sbercloud_compute_instance.aass[1].access_ip_v4} ${sbercloud_compute_instance.fleetmanager[0].access_ip_v4} ${sbercloud_compute_instance.fleetmanager[1].access_ip_v4} ${var.ecs_password} ${sbercloud_lb_loadbalancer.elb_aass.vip_address} ${sbercloud_rds_instance.mysql.fixed_ip} ${var.rds_password} "" "" ${sbercloud_dcs_instance.redis.ip} ${var.redis_password} ${sbercloud_lb_loadbalancer.elb_appgateway.vip_address} ${var.enterprise_project_id} ${var.domain_id} ${var.access_key} ${var.secret_access_key} ${sbercloud_obs_bucket.bucket.bucket} ${sbercloud_vpc_eip.eip[0].address} ${sbercloud_vpc_eip.eip[1].address} ${sbercloud_vpc_eip.eip[2].address} ${sbercloud_vpc_eip.eip[3].address}> /tmp/init_backend.log 2>&1
      rm -rf /tmp/init-backend.sh
    EOF
  )
}

resource "sbercloud_compute_instance" "appgateway2" {
  name              = "${var.ecs_name}-appgateway02"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  security_groups   = [sbercloud_networking_secgroup.secgroup.name]
  availability_zone = local.az[1]
  admin_pass        = var.ecs_password

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  system_disk_type = "SSD"
  system_disk_size = var.ecs_disk_size

  scheduler_hints {
    group = sbercloud_compute_servergroup.servergroup.id
  }
}

resource "sbercloud_compute_instance" "aass" {
  count             = 2
  name              = "${var.ecs_name}-aass${format("%02d", count.index + 1)}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  security_groups   = [sbercloud_networking_secgroup.secgroup.name]
  availability_zone = local.az[count.index % 2]
  admin_pass        = var.ecs_password

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  system_disk_type = "SSD"
  system_disk_size = var.ecs_disk_size

  scheduler_hints {
    group = sbercloud_compute_servergroup.servergroup.id
  }
}

resource "sbercloud_compute_instance" "fleetmanager" {
  count             = 2
  name              = "${var.ecs_name}-fleetmanager${format("%02d", count.index + 1)}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  security_groups   = [sbercloud_networking_secgroup.secgroup.name]
  availability_zone = local.az[count.index % 2]
  admin_pass        = var.ecs_password

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  system_disk_type = "SSD"
  system_disk_size = var.ecs_disk_size

  scheduler_hints {
    group = sbercloud_compute_servergroup.servergroup.id
  }
}

resource "sbercloud_compute_instance" "console" {
  depends_on        = [sbercloud_compute_instance.appgateway1]
  name              = "${var.ecs_name}-console"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  security_groups   = [sbercloud_networking_secgroup.secgroup.name]
  availability_zone = local.az[0]
  admin_pass        = var.ecs_password

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  system_disk_type = "SSD"
  system_disk_size = var.ecs_disk_size

  user_data = base64encode(
    <<-EOF
      #!/bin/bash
      echo 'root:${var.ecs_password}' | chpasswd
      wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-console.sh
      chmod +x /tmp/init-console.sh
      sh /tmp/init-console.sh ${sbercloud_compute_instance.appgateway1.access_ip_v4} ${var.ecs_password} ${sbercloud_lb_loadbalancer.elb_fleetmanager.vip_address} > /tmp/init-console.log 2>&1
      rm -rf /tmp/init-console.sh
    EOF
  )
}

# RDS инстанс
resource "sbercloud_rds_instance" "mysql" {
  name              = var.rds_name
  flavor            = var.rds_flavor
  vpc_id            = sbercloud_vpc.vpc.id
  subnet_id         = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  availability_zone = [local.az[0], local.az[1]]

  db {
    type     = "MySQL"
    version  = "5.7"
    password = var.rds_password
  }

  volume {
    type = "ULTRAHIGH"
    size = var.rds_volume_size
  }

  backup_strategy {
    start_time = "03:00-04:00"
    keep_days  = 7
  }
}

# Базы данных RDS
resource "sbercloud_rds_database" "appgateway_database" {
  instance_id   = sbercloud_rds_instance.mysql.id
  name          = "appgateway"
  character_set = "utf8mb4"
}

resource "sbercloud_rds_database" "aass_database" {
  instance_id   = sbercloud_rds_instance.mysql.id
  name          = "aass"
  character_set = "utf8mb4"
}

resource "sbercloud_rds_database" "fleetmanager_database" {
  instance_id   = sbercloud_rds_instance.mysql.id
  name          = "fleetmanager"
  character_set = "utf8mb4"
}

# Пользователи RDS
resource "sbercloud_rds_account" "user_appgateway" {
  instance_id = sbercloud_rds_instance.mysql.id
  name       = "appgateway"
  password   = var.rds_password
}

resource "sbercloud_rds_account" "user_aass" {
  instance_id = sbercloud_rds_instance.mysql.id
  name       = "aass"
  password   = var.rds_password
}

resource "sbercloud_rds_account" "user_fleetmanager" {
  instance_id = sbercloud_rds_instance.mysql.id
  name       = "fleetmanager"
  password   = var.rds_password
}

# Redis инстанс
resource "sbercloud_dcs_instance" "redis" {
  name              = var.redis_name
  engine           = "Redis"
  engine_version   = "5.0"
  capacity         = var.redis_capacity
  flavor           = data.sbercloud_dcs_flavors.dcs_flavors.flavors[0].name
  availability_zone = [local.az[0], local.az[1]]
  password         = var.redis_password
  vpc_id           = sbercloud_vpc.vpc.id
  subnet_id        = sbercloud_vpc_subnet.subnet.id
}

# Балансировщики нагрузки
resource "sbercloud_lb_loadbalancer" "elb_appgateway" {
  name          = "${var.elb_name}_appgateway"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.subnet_id
}

resource "sbercloud_lb_loadbalancer" "elb_aass" {
  name          = "${var.elb_name}_aass"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.subnet_id
}

resource "sbercloud_lb_loadbalancer" "elb_fleetmanager" {
  name          = "${var.elb_name}_fleetmanager"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.subnet_id
}

# Листенеры балансировщиков
resource "sbercloud_lb_listener" "elb_listener_appgateway" {
  name            = "listener_appgateway"
  protocol        = "TCP"
  protocol_port   = 60003
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_appgateway.id
}

resource "sbercloud_lb_listener" "elb_listener_aass" {
  name            = "listener_aass"
  protocol        = "TCP"
  protocol_port   = 9091
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_aass.id
}

resource "sbercloud_lb_listener" "elb_listener_fleetmanager" {
  name            = "listener_fleetmanager"
  protocol        = "TCP"
  protocol_port   = 31002
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_fleetmanager.id
}

# Пулы балансировщиков
resource "sbercloud_lb_pool" "elb_pool_appgateway" {
  name        = "pool_appgateway"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_appgateway.id
}

resource "sbercloud_lb_pool" "elb_pool_aass" {
  name        = "pool_aass"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_aass.id
}

resource "sbercloud_lb_pool" "elb_pool_fleetmanager" {
  name        = "pool_fleetmanager"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.elb_listener_fleetmanager.id
}

# Члены пулов
resource "sbercloud_lb_member" "elb_member_appgateway" {
  count         = 2
  address       = count.index == 0 ? sbercloud_compute_instance.appgateway1.access_ip_v4 : sbercloud_compute_instance.appgateway2.access_ip_v4
  protocol_port = 60003
  pool_id       = sbercloud_lb_pool.elb_pool_appgateway.id
  subnet_id     = sbercloud_vpc_subnet.subnet.subnet_id
}

resource "sbercloud_lb_member" "elb_member_aass" {
  count         = 2
  address       = sbercloud_compute_instance.aass[count.index].access_ip_v4
  protocol_port = 9091
  pool_id       = sbercloud_lb_pool.elb_pool_aass.id
  subnet_id     = sbercloud_vpc_subnet.subnet.subnet_id
}

resource "sbercloud_lb_member" "elb_member_fleetmanager" {
  count         = 2
  address       = sbercloud_compute_instance.fleetmanager[count.index].access_ip_v4
  protocol_port = 31002
  pool_id       = sbercloud_lb_pool.elb_pool_fleetmanager.id
  subnet_id     = sbercloud_vpc_subnet.subnet.subnet_id
}

# Health monitors
resource "sbercloud_lb_monitor" "elb_monitor_appgateway" {
  pool_id      = sbercloud_lb_pool.elb_pool_appgateway.id
  type         = "TCP"
  delay        = 5
  timeout      = 3
  max_retries  = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_aass" {
  pool_id      = sbercloud_lb_pool.elb_pool_aass.id
  type         = "TCP"
  delay        = 5
  timeout      = 3
  max_retries  = 3
}

resource "sbercloud_lb_monitor" "elb_monitor_fleetmanager" {
  pool_id      = sbercloud_lb_pool.elb_pool_fleetmanager.id
  type         = "TCP"
  delay        = 5
  timeout      = 3
  max_retries  = 3
}

# Привязка EIP к балансировщикам
resource "sbercloud_vpc_eip_associate" "eip_associate_appgateway" {
  public_ip = sbercloud_vpc_eip.eip[7].address
  port_id   = sbercloud_lb_loadbalancer.elb_appgateway.vip_port_id
}

resource "sbercloud_vpc_eip_associate" "eip_associate_fleetmanager" {
  public_ip = sbercloud_vpc_eip.eip[8].address
  port_id   = sbercloud_lb_loadbalancer.elb_fleetmanager.vip_port_id
}

# IAM роль и агентство
resource "sbercloud_identity_role" "smn_role" {
  name        = "${var.iam_agency_name}_role"
  description = "Allow SMN to send message notifications"
  type        = "XA"
  policy      = jsonencode({
    Version = "1.1"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "smn:topic:update",
          "smn:topic:create",
          "smn:topic:delete",
          "smn:topic:list",
          "smn:topic:publish"
        ]
      }
    ]
  })
}

resource "sbercloud_identity_agency" "agency" {
  name                   = var.iam_agency_name
  delegated_service_name = "op_svc_ecs"
  project_role {
    project = "ru-moscow-1"
    roles   = [
      "LTS Administrator",
      "APM Administrator",
      "Tenant Guest",
      "Tenant Administrator",
      sbercloud_identity_role.smn_role.name
    ]
  }
} 