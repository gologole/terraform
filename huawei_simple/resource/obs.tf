# Корзина OBS для хранения данных
resource "huaweicloud_obs_bucket" "bucket" {
  acl     = "private"                                  # Приватный доступ
  bucket  = "${var.obs_bucket_name}-obs"               # Имя корзины
  multi_az = false                                      # Без мультизональности
}