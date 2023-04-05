module "auditor" {
  source = "../.."

  name       = var.name
  project_id = local.project
  region     = var.region
}
