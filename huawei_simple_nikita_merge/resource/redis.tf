resource "sbercloud_dcs_instance" "redis_instance" {
  name               = var.redis_name
  engine             = "Redis"
  engine_version     = "5.0"
  capacity           = var.redis_capacity
  flavor             = var.redis_flavor
  availability_zones = var.availability_zones
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  security_group_id  = var.security_group_id
  password           = var.redis_password
  whitelist_enable   = false

  backup_policy {
    backup_type = "auto"
    save_days   = 3
    backup_at   = [1, 3, 5, 7]
    begin_at    = "02:00-04:00"
  }

  charging_mode = var.charge_mode
  period_unit   = var.charge_period_unit
  period        = var.charge_period
}
