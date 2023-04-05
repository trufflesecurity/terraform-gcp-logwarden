module "auditor" {
  source = "../.."

  name                = var.name
  project_id          = local.project
  logging_sink_filter = var.filter
}
