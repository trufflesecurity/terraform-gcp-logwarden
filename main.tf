resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

#TODO min/max instances 1
resource "google_cloud_run_v2_service" "auditor" {
  name     = "gcp-auditor"
  location = var.region
  ingress  = var.ingress

  template {
    scaling {
      max_instance_count = 1
      min_instance_count = 1
    }
    containers {
      image = var.docker_image
    }
    volumes {
      name = "rego-policy-declarations"
      gcs {
        bucket = google_storage_bucket.rego_policies.name
        path   = "/"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloudrun]
}

resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  secret_id = each.key
  replication {
    automatic = true
  }
  depends_on = [google_project_service.cloudrun]
}

resource "google_secret_manager_secret_version" "secrets_version" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.secrets[each.key].id
  secret_data = each.value
  depends_on  = [google_project_service.cloudrun]
}


resource "google_cloud_run_service_iam_member" "public_access" {
  service    = google_cloud_run_v2_service.auditor.name
  location   = google_cloud_run_v2_service.auditor.location
  role       = "roles/run.invoker"
  member     = "allUsers"
  depends_on = [google_project_service.cloudrun]
}

resource "google_storage_bucket" "rego_policies" {
  name     = "rego-policy-declarations-${var.project_id}"
  location = "US"
}

resource "google_logging_organization_sink" "audit-logs" {
  name        = "audit-logs-${var.environment}"
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
  name    = "audit-logs-${var.environment}"
  project = var.project_id
}

resource "google_pubsub_subscription" "gcp-auditor" {
  name    = "gcp-auditor-${var.environment}"
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

resource "google_pubsub_subscription" "gcp-auditor-test" {
  name    = "gcp-auditor-test"
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
