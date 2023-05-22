output "cloud_run_url" {
  #TODO interpolate full url string
  value       = google_cloud_run_v2_service.main.uri
  description = "URL of the deployed Cloud Run service"
}

output "policy_bucket_name" {
  value       = google_storage_bucket.rego_policies.name
  description = "Name of the GCS bucket where rego policies are uploaded."
}
