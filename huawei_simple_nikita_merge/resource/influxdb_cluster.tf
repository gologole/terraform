# Создание системных дисков для узлов InfluxDB
resource "sbercloud_evs_volume" "influxdb_system_disks" {
  count             = 3
  name              = "${var.influxdb_cluster_name}-node${count.index + 1}-system-disk"
  description       = "Системный диск для узла InfluxDB ${count.index + 1}"
  size              = var.influxdb_disk_size
  volume_type       = "SSD"
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % length(data.sbercloud_availability_zones.az.names)]
}

# Создание виртуальных машин для узлов InfluxDB
resource "sbercloud_compute_instance" "influxdb_nodes" {
  count             = 3
  name              = "${var.influxdb_cluster_name}-node${count.index + 1}"
  flavor_id         = var.influxdb_flavor
  image_id          = data.sbercloud_images_image.centos.id
  availability_zone = data.sbercloud_availability_zones.az.names[count.index % length(data.sbercloud_availability_zones.az.names)]
  admin_pass        = var.influxdb_password
  security_group_ids = [sbercloud_networking_secgroup.secgroup.id]

  network {
    uuid = sbercloud_vpc_subnet.subnet.id
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period

  user_data = <<-EOF
              #!/bin/bash
              # Установка и настройка InfluxDB
              curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
              echo "deb https://repos.influxdata.com/debian stable main" | sudo tee /etc/apt/sources.list.d/influxdb.list
              sudo apt-get update
              sudo apt-get install -y influxdb

              # Настройка конфигурации InfluxDB для кластера
              cat > /etc/influxdb/influxdb.conf <<EOL
              [meta]
                dir = "/var/lib/influxdb/meta"
                hostname = "${self.access_ip_v4}"
                bind-address = "${self.access_ip_v4}:8088"
                retention-autocreate = true
                election-timeout = "1s"
                heartbeat-timeout = "1s"
                leader-lease-timeout = "500ms"
                commit-timeout = "50ms"

              [data]
                dir = "/var/lib/influxdb/data"
                wal-dir = "/var/lib/influxdb/wal"
                query-log-enabled = true
                cache-max-memory-size = 1073741824
                cache-snapshot-memory-size = 26214400
                cache-snapshot-write-cold-duration = "10m"
                compact-full-write-cold-duration = "4h"

              [coordinator]
                write-timeout = "10s"
                max-concurrent-queries = 0
                query-timeout = "0s"
                log-queries-after = "0s"
                max-select-point = 0
                max-select-series = 0
                max-select-buckets = 0

              [retention]
                enabled = true
                check-interval = "30m"

              [shard-precreation]
                enabled = true
                check-interval = "10m"
                advance-period = "30m"

              [monitor]
                store-enabled = true
                store-database = "_internal"
                store-interval = "10s"

              [http]
                enabled = true
                bind-address = ":8086"
                auth-enabled = true
                log-enabled = true
                write-tracing = false
                pprof-enabled = true
                https-enabled = false
              EOL

              # Запуск InfluxDB
              sudo systemctl enable influxdb
              sudo systemctl start influxdb

              # Создание пользователя администратора
              sleep 10
              influx -execute "CREATE USER admin WITH PASSWORD '${var.influxdb_password}' WITH ALL PRIVILEGES"

              # Настройка кластера
              if [ ${count.index} -eq 0 ]; then
                # Первый узел - лидер
                influx -username admin -password '${var.influxdb_password}' -execute "CREATE DATABASE metrics"
              else
                # Остальные узлы - присоединяются к кластеру
                influx -username admin -password '${var.influxdb_password}' -execute "JOIN ${sbercloud_compute_instance.influxdb_nodes[0].access_ip_v4}:8088"
              fi
              EOF

  tags = {
    role = "influxdb-cluster"
    node = "node${count.index + 1}"
  }
}

# Прикрепление системных дисков к виртуальным машинам
resource "sbercloud_compute_volume_attach" "influxdb_volume_attachments" {
  count       = 3
  instance_id = sbercloud_compute_instance.influxdb_nodes[count.index].id
  volume_id   = sbercloud_evs_volume.influxdb_system_disks[count.index].id
}

# Создание правил безопасности для InfluxDB
resource "sbercloud_networking_secgroup_rule" "influxdb_cluster_rules" {
  count             = length(local.influxdb_ports)
  security_group_id = sbercloud_networking_secgroup.secgroup.id
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = local.influxdb_ports[count.index]
  port_range_max   = local.influxdb_ports[count.index]
  remote_group_id  = sbercloud_networking_secgroup.secgroup.id
}

locals {
  influxdb_ports = [8086, 8088] # 8086 для HTTP API, 8088 для кластерной коммуникации
} 