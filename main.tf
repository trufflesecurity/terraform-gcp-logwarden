resource "google_project_service" "auditor" {
  service = "run.googleapis.com"
}

resource "google_service_account" "auditor" {
  account_id   = "gcp-auditor-${var.environment}"
  display_name = "GCP Auditor Service Account"
}

#resource "google_cloud_v2_service_iam_member" "auditor" {
#project  = google_cloud_run_v2_service.auditor.project
#location = google_cloud_run_v2_service.auditor.location
#name     = google_cloud_run_v2_service.auditor.name
#role     = "roles/run.invoker"
#member   = "serviceAccount:${google_service_account.auditor.email}"
#}

resource "google_cloud_run_v2_service" "auditor" {
  name     = "gcp-auditor-${var.environment}"
  project  = var.project_id
  location = var.region
  ingress  = var.ingress

  template {

    service_account = google_service_account.auditor.email

    scaling {
      max_instance_count = 1
      min_instance_count = 1
    }

    volumes {
      name = "auditor-secrets"
      dynamic "secret" {
        for_each = google_secret_manager_secret.auditor_secrets
        content {
          secret       = secret.value["secret_id"]
          default_mode = 256
          items {
            version = "latest"
            path    = secret.value["secret_id"]
            mode    = 256
          }
        }
      }
    }

    containers {
      image = var.docker_image
      volume_mounts {
        name       = "auditor-secrets"
        mount_path = "/secrets"
      }
    }

  }

  traffic {
    percent = 100
  }

  depends_on = [google_project_service.auditor]
}

resource "google_secret_manager_secret" "auditor_secrets" {
  for_each  = var.secrets
  secret_id = each.key
  replication {
    automatic = true
  }
  depends_on = [google_project_service.auditor]
}

resource "google_secret_manager_secret_version" "auditor_secrets_version" {
  for_each    = var.secrets
  secret      = google_secret_manager_secret.auditor_secrets[each.key].id
  secret_data = each.value
  depends_on  = [google_project_service.auditor]
}

resource "google_storage_bucket_iam_member" "auditor" {
  bucket = google_storage_bucket.rego_policies.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.auditor.email}"
}

resource "google_storage_bucket" "rego_policies" {
  name     = "rego-policy-declarations-${var.environment}"
  location = var.region
}

resource "google_logging_organization_sink" "audit-logs" {
  name        = "audit-logs-${var.environment}"
  description = "audit logs for the organization"
  org_id      = var.organization_id
  destination = "pubsub.googleapis.com/${google_pubsub_topic.audit-logs.id}"

  include_children = true

  filter = var.logging_sink_filter
}

resource "google_pubsub_topic_iam_member" "sink_topic" {
  project = google_pubsub_topic.audit-logs.project
  topic   = google_pubsub_topic.audit-logs.name
  member  = google_logging_organization_sink.audit-logs.writer_identity
  role    = "roles/pubsub.publisher"
}

resource "google_pubsub_subscription_iam_member" "auditor" {
  subscription = google_pubsub_subscription.gcp-auditor.name
  member       = google_service_account.auditor.email
  role         = "roles/pubsub.subscriber"
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
  name    = "gcp-auditor-test-${var.environment}"
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
