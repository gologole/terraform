# Основные параметры проекта
enterprise_project_id = "0"  # ID проекта Huawei Cloud, по умолчанию "0"
domain_id = "5f055189d7fd4d27829e754dbd29faa3"              # ID аккаунта (32 символа, только строчные буквы и цифры)
access_key = "HPUAYQGEHVLDDG6D9REA"             # Ключ доступа (20 символов, только заглавные буквы и цифры)
secret_access_key = "xfLSvu3LnaqiBDkD74aHdqbRwyMj7p1ZaSZf99lL"      # Секретный ключ (40 символов, буквы и цифры)

# Параметры сети
vpc_name = "gameflexmatch-hosting-platform-demo"  # Имя VPC
security_group_name = "gameflexmatch-hosting-platform-demo"  # Имя группы безопасности
eip_bandwidth_size = 5  # Размер полосы пропускания EIP (1-2000 Мбит/с)

# Параметры хранилища
obs_bucket_name = "gameflexmatch-demo-obs"  # Префикс имени бакета OBS (1-59 символов)

# Параметры ECS
ecs_name = "gameflexmatch-hosting-platform-demo"  # Префикс имени ECS
ecs_flavor = "c7.large.2"  # Тип ECS
ecs_password = "GameFlexMatch@2024"  # Пароль для ECS (8-26 символов, минимум 3 типа символов)
ecs_disk_size = 100  # Размер системного диска (40-1024 ГБ)

# Параметры RDS MySQL
rds_name = "gameflexmatch-hosting-platform-demo"  # Имя RDS MySQL
rds_flavor = "rds.mysql.n1.large.2.ha"  # Тип RDS
rds_volume_size = 100  # Размер хранилища RDS (40-4000 ГБ)
rds_password = "GameFlexMatch@2024"  # Пароль для RDS (8-32 символов, минимум 3 типа символов)

# Параметры InfluxDB
influx_name = "gameflexmatch-hosting-platform-demo"  # Имя экземпляра InfluxDB
influx_flavor = "geminidb.influxdb.large.4"  # Тип InfluxDB
influx_volume_size = 100  # Размер хранилища (100-12000 ГБ)
influx_password = "GameFlexMatch@2024"  # Пароль для InfluxDB (8-32 символов)

# Параметры Redis
redis_name = "gameflexmatch-hosting-platform-demo"  # Имя экземпляра Redis
redis_capacity = 2  # Емкость кэша (0.125-64 ГБ)
redis_password = "GameFlexMatch@2024"  # Пароль для Redis (8-32 символов, минимум 3 типа символов)

# Параметры балансировщика
elb_name = "gameflexmatch-hosting-platform-demo"  # Префикс имени ELB

# Параметры IAM
iam_agency_name = "gameflexmatch-agency"  # Имя IAM-делегирования (1-59 символов)

# Параметры тарификации
charge_mode = "postPaid"  # Режим оплаты ("postPaid" или "prePaid")
charge_period_unit = "month"  # Единица периода оплаты ("month" или "year")
charge_period = 1  # Период оплаты (1-9 для месяцев, 1-3 для лет) 