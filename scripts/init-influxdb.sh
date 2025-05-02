#!/bin/bash

INFLUXDB_VERSION="1.7.9"
INFLUXDB_PASSWORD=$1

# Установка зависимостей
yum install -y curl wget

# Скачивание и установка InfluxDB
wget https://dl.influxdata.com/influxdb/releases/influxdb-${INFLUXDB_VERSION}.x86_64.rpm
yum localinstall -y influxdb-${INFLUXDB_VERSION}.x86_64.rpm

# Настройка конфигурации InfluxDB
cat > /etc/influxdb/influxdb.conf << EOF
[meta]
  dir = "/var/lib/influxdb/meta"

[data]
  dir = "/var/lib/influxdb/data"
  wal-dir = "/var/lib/influxdb/wal"

[http]
  enabled = true
  bind-address = ":8086"
  auth-enabled = true

[[graphite]]
  enabled = false

[[collectd]]
  enabled = false

[[opentsdb]]
  enabled = false

[[udp]]
  enabled = false
EOF

# Запуск InfluxDB
systemctl enable influxdb
systemctl start influxdb

# Ждем запуска сервиса
sleep 10

# Создание админского пользователя и базы данных
curl -XPOST "http://localhost:8086/query" --data-urlencode "q=CREATE USER admin WITH PASSWORD '${INFLUXDB_PASSWORD}' WITH ALL PRIVILEGES"
curl -XPOST "http://localhost:8086/query" -u "admin:${INFLUXDB_PASSWORD}" --data-urlencode "q=CREATE DATABASE gameflexmatch"

# Настройка retention policy
curl -XPOST "http://localhost:8086/query" -u "admin:${INFLUXDB_PASSWORD}" --data-urlencode "q=CREATE RETENTION POLICY \"gameflexmatch_retention\" ON \"gameflexmatch\" DURATION 30d REPLICATION 1 DEFAULT"

# Проверка статуса
systemctl status influxdb 