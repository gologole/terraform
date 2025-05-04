# Корзина OBS для хранения данных
resource "sbercloud_obs_bucket" "bucket" {
  bucket = "${var.obs_bucket_name}-obs"
  acl    = "private"
  multi_az = false
}