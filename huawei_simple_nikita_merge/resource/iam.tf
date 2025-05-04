resource "sbercloud_identity_agency" "smn_agency" {
  name                   = var.iam_agency_name
  description            = "Агентство для SMN"
  delegated_service_name = "smn"
}

resource "sbercloud_identity_agency_role" "smn_agency_roles" {
  agency_id = sbercloud_identity_agency.smn_agency.id
  project_id = var.project_id
  roles = [
    "SMN Administrator",
    "Tenant Guest"
  ]
}
