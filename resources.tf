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

# Группа безопасности
resource "sbercloud_networking_secgroup" "secgroup" {
  name        = var.security_group_name
  description = "Security group for GameFlexMatch"
}

# Правила группы безопасности
resource "sbercloud_networking_secgroup_rule" "allow_ssh" {
  direction        = "ingress"
  ethertype       = "IPv4"
  protocol        = "tcp"
  port_range_min  = 22
  port_range_max  = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_mysql" {
  direction        = "ingress"
  ethertype       = "IPv4"
  protocol        = "tcp"
  port_range_min  = 3306
  port_range_max  = 3306
  remote_ip_prefix = "192.168.0.0/16"
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

resource "sbercloud_networking_secgroup_rule" "allow_redis" {
  direction        = "ingress"
  ethertype       = "IPv4"
  protocol        = "tcp"
  port_range_min  = 6379
  port_range_max  = 6379
  remote_ip_prefix = "192.168.0.0/16"
  security_group_id = sbercloud_networking_secgroup.secgroup.id
}

# RDS инстанс
resource "sbercloud_rds_instance" "mysql" {
  name              = "${var.project_name}-mysql"
  flavor           = var.rds_flavor
  vpc_id           = sbercloud_vpc.vpc.id
  subnet_id        = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  availability_zone = [local.az[0]]
  
  db {
    type     = "MySQL"
    version  = "5.7"
    password = var.rds_password
    port     = 3306
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

# Redis инстанс
resource "sbercloud_dcs_instance" "redis" {
  name               = "${var.project_name}-redis"
  engine            = "Redis"
  engine_version     = "5.0"
  password          = var.redis_password
  flavor            = "redis.ha.xu1.large.r2.2"
  capacity          = 2
  vpc_id            = sbercloud_vpc.vpc.id
  subnet_id         = sbercloud_vpc_subnet.subnet.id
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  availability_zones = [local.az[0], local.az[1]]
  
  backup_policy {
    backup_type = "auto"
    save_days   = 1
    backup_at   = [1]
    begin_at    = "00:00-01:00"
  }
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
  name              = "${var.ecs_name}-appgateway1"
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

  data_disks {
    type = "SSD"
    size = "100"
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "${var.ecs_password}" | passwd --stdin root
              sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
              sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF
  )
}

# Привязка EIP к инстансам
resource "sbercloud_networking_eip_associate" "appgateway1_eip" {
  public_ip = sbercloud_vpc_eip.eip[0].address
  port_id   = sbercloud_compute_instance.appgateway1.network[0].port
}

# Load Balancer
resource "sbercloud_lb_loadbalancer" "elb_appgateway" {
  name          = "${var.elb_name}-appgateway"
  description   = "ELB for AppGateway"
  vip_subnet_id = sbercloud_vpc_subnet.subnet.id
}

resource "sbercloud_lb_listener" "listener_appgateway" {
  name            = "${var.elb_name}-listener-appgateway"
  protocol        = "TCP"
  protocol_port   = 60003
  loadbalancer_id = sbercloud_lb_loadbalancer.elb_appgateway.id
}

resource "sbercloud_lb_pool" "pool_appgateway" {
  name        = "${var.elb_name}-pool-appgateway"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.listener_appgateway.id
}

resource "sbercloud_lb_member" "member_appgateway1" {
  address       = sbercloud_compute_instance.appgateway1.access_ip_v4
  protocol_port = 60003
  pool_id       = sbercloud_lb_pool.pool_appgateway.id
  subnet_id     = sbercloud_vpc_subnet.subnet.id
}

# Привязка EIP к Load Balancer
resource "sbercloud_networking_eip_associate" "elb_appgateway_eip" {
  public_ip = sbercloud_vpc_eip.eip[8].address
  port_id   = sbercloud_lb_loadbalancer.elb_appgateway.vip_port_id
} 