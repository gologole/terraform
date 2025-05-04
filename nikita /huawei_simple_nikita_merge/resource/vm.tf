# Создание системного диска для Appgateway01
resource "sbercloud_evs_volume" "appgateway01_sysdisk" {
  name        = "${var.ecs_name}-appgateway01-sysdisk"
  description = "Системный диск для Appgateway01"
  size        = var.ecs_disk_size
  volume_type = "SSD"  # Убедитесь, что тип диска поддерживается в вашем регионе
  availability_zone = data.sbercloud_availability_zones.az.names[0]
}

# Создание виртуальной машины Appgateway01
resource "sbercloud_compute_instance" "appgateway01" {
  name              = "${var.ecs_name}-appgateway01"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  admin_pass        = var.ecs_password
  security_group_ids = [sbercloud_networking_secgroup.secgroup.id]
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = <<-EOF
    #!/bin/bash
    echo "root:${var.ecs_password}" | chpasswd
    wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh
    chmod +x /tmp/init-backend.sh
    sh /tmp/init-backend.sh \
      ${sbercloud_compute_instance.appgateway02.access_ip_v4} \
      ${sbercloud_compute_instance.aass[0].access_ip_v4} \
      ${sbercloud_compute_instance.aass[1].access_ip_v4} \
      ${sbercloud_compute_instance.fleetmanager[0].access_ip_v4} \
      ${sbercloud_compute_instance.fleetmanager[1].access_ip_v4} \
      ${var.ecs_password} \
      ${sbercloud_lb_loadbalancer.elb_aass.vip_address} \
      ${data.sbercloud_rds_instances.rds_instance.instances[0].fixed_ip} \
      ${var.rds_password} \
      ${sbercloud_gaussdb_influx_instance.gaussdb_influx_instance.lb_ip_address} \
      ${var.influx_password} \
      ${sbercloud_dcs_instance.redis_instance.private_ip} \
      ${var.redis_password} \
      ${sbercloud_lb_loadbalancer.elb_appgateway.vip_address} \
      ${var.enterprise_project_id} \
      ${var.domain_id} \
      ${var.access_key} \
      ${var.secret_access_key} \
      ${sbercloud_obs_bucket.bucket.bucket} \
      ${sbercloud_vpc_eip.eip[0].address} \
      ${sbercloud_vpc_eip.eip[1].address} \
      ${sbercloud_vpc_eip.eip[2].address} \
      ${sbercloud_vpc_eip.eip[3].address} > /tmp/init_backend.log 2>&1
    rm -rf /tmp/init-backend.sh
    EOF
}

# Прикрепление системного диска к виртуальной машине Appgateway01
resource "sbercloud_compute_volume_attach" "appgateway01_sysdisk_attach" {
  instance_id = sbercloud_compute_instance.appgateway01.id
  volume_id   = sbercloud_evs_volume.appgateway01_sysdisk.id
}


# Appgateway02
resource "sbercloud_evs_volume" "appgateway02_system_disk" {
  name              = "${var.ecs_name}-appgateway02-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[1]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "appgateway02" {
  name              = "${var.ecs_name}-appgateway02"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[1]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode     = var.charge_mode
  period_unit       = var.charge_period_unit
  period            = var.charge_period
}

resource "sbercloud_compute_volume_attachment" "appgateway02_attachment" {
  instance_id = sbercloud_compute_instance.appgateway02.id
  volume_id   = sbercloud_evs_volume.appgateway02_system_disk.id
}

# AASS Instances
resource "sbercloud_evs_volume" "aass_system_disks" {
  count             = 2
  name              = "${var.ecs_name}-aass0${count.index + 1}-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "aass" {
  count             = 2
  name              = "${var.ecs_name}-aass0${count.index + 1}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode     = var.charge_mode
  period_unit       = var.charge_period_unit
  period            = var.charge_period
  user_data         = filebase64("${path.module}/user_data/aass0${count.index + 1}.sh")
}

resource "sbercloud_compute_volume_attachment" "aass_attachments" {
  count       = 2
  instance_id = sbercloud_compute_instance.aass[count.index].id
  volume_id   = sbercloud_evs_volume.aass_system_disks[count.index].id
}

# Fleetmanager Instances
resource "sbercloud_evs_volume" "fleetmanager_system_disks" {
  count             = 2
  name              = "${var.ecs_name}-fleetmanager0${count.index + 1}-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "fleetmanager" {
  count             = 2
  name              = "${var.ecs_name}-fleetmanager0${count.index + 1}"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % 2]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode     = var.charge_mode
  period_unit       = var.charge_period_unit
  period            = var.charge_period
  user_data         = filebase64("${path.module}/user_data/fleetmanager0${count.index + 1}.sh")
}

resource "sbercloud_compute_volume_attachment" "fleetmanager_attachments" {
  count       = 2
  instance_id = sbercloud_compute_instance.fleetmanager[count.index].id
  volume_id   = sbercloud_evs_volume.fleetmanager_system_disks[count.index].id
}

# Console
resource "sbercloud_evs_volume" "console_system_disk" {
  name              = "${var.ecs_name}-console-system-disk"
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  size              = var.ecs_disk_size
  volume_type       = "GPSSD"
  image_id          = data.sbercloud_images_image.centos.id
}

resource "sbercloud_compute_instance" "console" {
  name              = "${var.ecs_name}-console"
  flavor_id         = var.ecs_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  security_groups   = [sbercloud_networking_secgroup.secgroup.id]
  key_pair          = var.keypair_name
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode     = var.charge_mode
  period_unit       = var.charge_period_unit
  period            = var.charge_period
  user_data         = filebase64("${path.module}/user_data/console.sh")
}

resource "sbercloud_compute_volume_attachment" "console_attachment" {
  instance_id = sbercloud_compute_instance.console.id
  volume_id   = sbercloud_evs_volume.console_system_disk.id
}

# Создание системного диска для influxDB
resource "sbercloud_evs_volume" "influxDB" {
  name        = "${var.influx_name}-influxDB"
  description = "Системный диск для influxDB"
  size        = var.influx_volume_size
  volume_type = "SSD"  # Убедитесь, что тип диска поддерживается в вашем регионе
  availability_zone = data.sbercloud_availability_zones.az.names[0]
}

############################################################## ИИЗМЕНИТЬ ЭТО
# Создание виртуальной машины influxDB
resource "sbercloud_compute_instance" "influxDB" {
  name              = "${var.influx_name}-influxDB"
  flavor_id         = var.influx_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[0]
  admin_pass        = var.influx_password
  security_group_ids = [sbercloud_networking_secgroup.secgroup.id]
  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }
  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
  user_data     = <<-EOF
    #!/bin/bash
    echo "root:${var.influx_password}" | chpasswd
    wget -P /tmp/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/game-hosting-platform-based-on-gameflexmatch/userdata/init-backend.sh
    chmod +x /tmp/init-backend.sh
    sh /tmp/init-influxdb.sh \
      ${var.influx_password} \
    rm -rf /tmp/init-influxdb.sh
    EOF
}

# Прикрепление системного диска к виртуальной машине influxDB
resource "sbercloud_compute_volume_attach" "influxDB_sysdisk_attach" {
  instance_id = sbercloud_compute_instance.influxDB.id
  volume_id   = sbercloud_evs_volume.influxDB.id
}