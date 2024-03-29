variable "environment" {
  type        = string
  description = "Environment of app, service, or context using this module."
}

variable "project_id" {
  type        = string
  description = "ID of the parent project. Needed for service account IAM bindings."
}

variable "ingress" {
  description = "Ingress settings for the Google Cloud Run service"
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

variable "region" {
  type        = string
  description = "Region to place the CloudRun function in."
}

variable "organization_id" {
  type        = string
  description = "ID of the parent organization."
}

variable "logging_sink_filter" {
  type    = string
  default = <<EOF
LOG_ID("cloudaudit.googleapis.com/activity") OR LOG_ID("externalaudit.googleapis.com/activity") OR LOG_ID("cloudaudit.googleapis.com/system_event") OR LOG_ID("externalaudit.googleapis.com/system_event") OR LOG_ID("cloudaudit.googleapis.com/access_transparency") OR LOG_ID("externalaudit.googleapis.com/access_transparency")
-protoPayload.serviceName="k8s.io"
EOF
}

variable "docker_image" {
  type        = string
  description = "Docker image for the logwarden tool. Used by Cloud Run"
}

variable "config_secret_id" {
  type        = string
  description = "GCP Secret Manager secret name/id for environment variable string."
}

variable "container_args" {
  description = "Runtime arguments for logwarden"
  type        = list(string)
  default     = []
}

variable "policy_source_dir" {
  type        = string
  description = "Repository folder where rego policies are stored."
}

