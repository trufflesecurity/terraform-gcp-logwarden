locals {
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

#TODO min/max instances 1
resource "google_cloud_run_v2_service" "main" {
  name     = "truffle-logwarden-${var.region}-${var.environment}"
  location = var.region
  ingress  = var.ingress

  template {
    service_account = google_service_account.main.email
    scaling {
      max_instance_count = 1
      min_instance_count = 1
    }
    containers {
      image = var.docker_image
      args = [
        "--subscription=${google_pubsub_subscription.logwarden.name}",
        "--project=${var.project_id}",
        "--secret-name=${var.env_secrets}",
      ]
    }
  }

  depends_on = [google_project_service.cloudrun]
}

resource "google_service_account" "main" {
  account_id = "truffle-logwarden-${var.region}-${var.environment}"
  project    = var.project_id
}

resource "google_project_iam_member" "run" {
  project = var.project_id
  member  = google_service_account.main.email
  role    = "roles/run.invoker"
}

resource "google_project_iam_member" "secret" {
  project = var.project_id
  member  = google_service_account.main.email
  role    = "roles/secretmanager.secretAccessor"
}

resource "google_storage_bucket" "rego_policies" {
  name     = "truffle-logwarden-policies-${var.region}-${var.environment}"
  location = "US"

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = "true"
}

resource "google_logging_organization_sink" "audit-logs" {
  name        = "truffle-logwarden-audit-logs-${var.region}-${var.environment}"
  description = "audit logs for the organization"
  org_id      = var.organization_id

  destination = "pubsub.googleapis.com/${google_pubsub_topic.audit-logs.id}"

  include_children = true

  filter = var.logging_sink_filter
}

data "google_iam_policy" "sink_topic_iam_policy_data" {
  binding {
    members = [google_logging_organization_sink.audit-logs.writer_identity]
    role    = "roles/pubsub.publisher"
  }
}

resource "google_pubsub_topic_iam_policy" "sink_topic_iam_poicy" {
  project     = var.project_id
  policy_data = data.google_iam_policy.sink_topic_iam_policy_data.policy_data
  topic       = google_pubsub_topic.audit-logs.name
}

resource "google_pubsub_topic" "audit-logs" {
  name    = "truffle-logwarden-audit-logs-${var.region}-${var.environment}"
  project = var.project_id
}

resource "google_pubsub_subscription" "logwarden" {
  name    = "truffle-logwarden-audit-logs-sub-${var.region}-${var.environment}"
  topic   = google_pubsub_topic.audit-logs.name
  project = var.project_id

  message_retention_duration = "3600s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "432000s" // 5 days, but 24h is the minimum
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}

resource "google_pubsub_subscription" "logwarden-test" {
  name    = "truffle-logwarden-audit-logs-sub-test-${var.region}-${var.environment}"
  topic   = google_pubsub_topic.audit-logs.name
  project = var.project_id

  message_retention_duration = "3600s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "86400s" // 24h is the minimum
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}
