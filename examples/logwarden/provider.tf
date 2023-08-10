terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }
  }
}


provider "google" {
  project         = var.project_id
  request_timeout = "60s"
  region          = var.region
}
