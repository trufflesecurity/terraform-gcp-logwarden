# terraform-gcp-auditor
Terraform module for the GCP auditor

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.48.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/cloud_run_v2_service) | resource |
| [google_cloud_v2_service_iam_member.auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/cloud_v2_service_iam_member) | resource |
| [google_logging_organization_sink.audit-logs](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/logging_organization_sink) | resource |
| [google_project_service.auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/project_service) | resource |
| [google_pubsub_subscription.gcp-auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.gcp-auditor-test](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.audit-logs](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.sink_topic](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/pubsub_topic_iam_member) | resource |
| [google_secret_manager_secret.auditor_secrets](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.auditor_secrets_version](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/service_account) | resource |
| [google_storage_bucket.rego_policies](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.auditor](https://registry.terraform.io/providers/hashicorp/google/4.48.0/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image for the auditor tool. Used by Cloud Run | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment of app, service, or context using this module. | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress settings for the Google Cloud Run service | `string` | `"all"` | no |
| <a name="input_logging_sink_filter"></a> [logging\_sink\_filter](#input\_logging\_sink\_filter) | n/a | `string` | `"LOG_ID(\"cloudaudit.googleapis.com/activity\") OR LOG_ID(\"externalaudit.googleapis.com/activity\") OR LOG_ID(\"cloudaudit.googleapis.com/system_event\") OR LOG_ID(\"externalaudit.googleapis.com/system_event\") OR LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") OR LOG_ID(\"externalaudit.googleapis.com/access_transparency\")\n-protoPayload.serviceName=\"k8s.io\"\n"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | ID of the parent organization. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the parent project. Needed for service account IAM bindings. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to place the CloudRun function in. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to be stored in Secret Manager | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_url"></a> [cloud\_run\_url](#output\_cloud\_run\_url) | URL of the deployed Cloud Run service |
| <a name="output_policy_bucket_name"></a> [policy\_bucket\_name](#output\_policy\_bucket\_name) | Name of the GCS bucket where rego policies are uploaded. |
<!-- END_TF_DOCS -->