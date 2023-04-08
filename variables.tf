variable "name" {
  type        = string
  description = "Name of app, service, or context using this module."
}

variable "project_id" {
  type        = string
  description = "ID of the parent project. Needed for service account IAM bindings."
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
