data "sbercloud_images_image" "centos" {
  name        = "CentOS 7.9 64bit"
  visibility  = "public"
  most_recent = true
}

data "sbercloud_availability_zones" "zones" {} 