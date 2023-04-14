module "auditor" {
  source = "../.."

  project_id          = local.project
  environment         = var.environment
  logging_sink_filter = var.filter
  organization_id     = var.organization_id
  region              = var.region
}
