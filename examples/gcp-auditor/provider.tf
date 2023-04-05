locals {
  terraform_service_account = "terraform-testing@thog-admin.iam.gserviceaccount.com"
  project                   = "terraform-test-project-0000"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.48.0"
    }
  }
}


provider "google" {
  project         = local.project
  request_timeout = "60s"
}
