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
      args = [
        "--subscription=${google_pubsub_subscription.logwarden.name}",
        "--project=${var.project_id}",
        "--secret-name=${var.env_secret_id}",
      ]
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
    google_pubsub_subscription.logwarden
  ]
}

resource "google_cloud_run_v2_service_iam_member" "main" {
  project = var.project_id
  name    = google_cloud_run_v2_service.main.name
  member  = google_service_account.main.member
  role    = "roles/run.invoker"
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

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = "true"
}

resource "google_logging_organization_sink" "audit_logs" {
  name        = "logwarden-audit-logs-${var.region}-${var.environment}"
  description = "audit logs for the organization"
  org_id      = var.organization_id

  destination = "pubsub.googleapis.com/${google_pubsub_topic.audit_logs.id}"

  include_children = true

  filter = var.logging_sink_filter
}

resource "google_pubsub_topic" "audit_logs" {
  name    = "logwarden-audit-logs-${var.region}-${var.environment}"
  project = var.project_id
}

module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 5.0"

  topic      = google_pubsub_topic.audit_logs.name
  project_id = var.project_id

  pull_subscriptions = [
    {
      name            = "logwarden-audit-logs-sub-test-${var.region}-${var.environment}"
      service_account = google_service_account.main.email
    }
  ]
}
