# Роль IAM для SMN
resource "huaweicloud_identity_role" "smn_role" {
  name        = "${var.iam_agency_name}_role"          # Имя роли
  description = "Разрешить SMN отправлять уведомления" # Описание
  type        = "XA"
  policy      = <<-POLICY
  {
    "Version": "1.1",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "smn:topic:update",
          "smn:topic:create",
          "smn:topic:delete",
          "smn:topic:list",
          "smn:topic:publish"
        ]
      }
    ]
  }
  POLICY
}

# Агентство IAM (Agency)
resource "huaweicloud_identity_agency" "identity_agency" {
  name                   = var.iam_agency_name
  delegated_service_name = "op_svc_ecs"                    # Доверенный сервис ECS
  project_role {
    project = "cn-north-4"                                 # ID региона/проекта
    roles   = [
      "LTS Administrator",
      "APM Administrator",
      "Tenant Guest",
      "Tenant Administrator",
      huaweicloud_identity_role.smn_role.name               # Добавляем роль SMN
    ]
  }
}
