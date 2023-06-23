locals {
  default_args = [
    "--subscription=${google_pubsub_subscription.logwarden.name}",
    "--project=${var.project_id}",
    "--secret-name=${var.env_secret_id}",
    "--policies=gs://${google_storage_bucket.rego_policies.name}",
    "--json"
  ]
  run_args = concat(local.default_args, var.container_args)

  source_dir = var.policy_source_dir
  files      = fileset(local.source_dir, ".rego")
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

#TODO min/max instances 1
resource "google_cloud_run_v2_service" "main" {
  name     = "logwarden-${var.region}-${var.environment}"
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
      args  = local.run_args
      ports {
        container_port = 8080
      }

      startup_probe {
        initial_delay_seconds = 120
        tcp_socket {
        }
      }
    }
  }

  depends_on = [
    google_project_service.cloudrun,
    google_service_account.main,
    google_pubsub_subscription.logwarden,
    google_storage_bucket.rego_policies
  ]
}

resource "google_service_account" "main" {
  account_id = "logwarden-${var.region}-${var.environment}"
  project    = var.project_id
}

data "google_secret_manager_secret" "env" {
  project   = var.project_id
  secret_id = var.env_secret_id
}

resource "google_project_iam_member" "service" {
  project = var.project_id
  member  = google_service_account.main.member
  role    = "roles/iam.serviceAccountUser"
}

resource "google_secret_manager_secret_iam_member" "env" {
  project   = var.project_id
  member    = google_service_account.main.member
  secret_id = data.google_secret_manager_secret.env.id
  role      = "roles/secretmanager.secretAccessor"
}

resource "google_storage_bucket" "rego_policies" {
  name     = "logwarden-policies-${var.region}-${var.environment}"
  location = "US"

  force_destroy               = "true"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = "true"
}

resource "google_storage_bucket_object" "policies" {
  for_each = { for file in local.files : file => file }
  name     = each.key
  bucket   = google_storage_bucket.rego_policies.name
  source   = "${local.source_dir}/${each.key}"
}

resource "google_logging_organization_sink" "audit_logs" {
  name        = "logwarden-audit-logs-${var.region}-${var.environment}"
  description = "audit logs for the organization"
  org_id      = var.organization_id

  destination = "pubsub.googleapis.com/${google_pubsub_topic.audit_logs.id}"

  include_children = true

  filter = var.logging_sink_filter
}

resource "google_pubsub_subscription_iam_member" "pubsub" {
  project      = var.project_id
  subscription = google_pubsub_subscription.logwarden.id
  role         = "roles/pubsub.subscriber"
  member       = google_service_account.main.member

  depends_on = [
    google_pubsub_subscription.logwarden
  ]
}

resource "google_pubsub_topic" "audit_logs" {
  name    = "logwarden-audit-logs-${var.region}-${var.environment}"
  project = var.project_id
}

resource "google_pubsub_subscription" "logwarden" {
  name    = "logwarden-audit-logs-sub-${var.region}-${var.environment}"
  topic   = google_pubsub_topic.audit_logs.id
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
  depends_on              = [google_pubsub_topic.audit_logs]
}

resource "google_pubsub_subscription" "logwarden-test" {
  name    = "logwarden-audit-logs-sub-test-${var.region}-${var.environment}"
  topic   = google_pubsub_topic.audit_logs.name
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
