module "logwarden" {
  source = "../.."

  project_id          = local.project
  environment         = var.environment
  logging_sink_filter = var.filter
  organization_id     = var.organization_id
  ingress             = var.ingress
  region              = var.region
  docker_image        = var.docker_image
  config_secret_id    = var.config_secret_id
  container_args      = var.container_args
  policy_source_dir   = var.policy_source_dir
}
