module "auditor" {
  source = "../.."

  project_id          = local.project
  environment         = var.environment
  logging_sink_filter = var.filter
  organization_id     = var.organization_id
  ingress             = var.ingress
  region              = var.region
  docker_image        = var.docker_image
  env_secrets         = var.env_secrets
}
