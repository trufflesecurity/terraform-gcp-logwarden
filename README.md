# terraform-gcp-logwarden

Terraform module for GCP Logwarden

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=4.61.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=4.61.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_logging_organization_sink.audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_project_iam_member.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.cloudrun](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_pubsub_subscription.logwarden](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_secret_manager_secret_iam_member.config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.rego_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_secret_manager_secret.config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_secret_id"></a> [config\_secret\_id](#input\_config\_secret\_id) | GCP Secret Manager secret name/id for environment variable string. | `string` | n/a | yes |
| <a name="input_container_args"></a> [container\_args](#input\_container\_args) | Runtime arguments for logwarden | `list(string)` | `[]` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image for the auditor tool. Used by Cloud Run | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment of app, service, or context using this module. | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress settings for the Google Cloud Run service | `string` | `"INGRESS_TRAFFIC_INTERNAL_ONLY"` | no |
| <a name="input_logging_sink_filter"></a> [logging\_sink\_filter](#input\_logging\_sink\_filter) | n/a | `string` | `"LOG_ID(\"cloudaudit.googleapis.com/activity\") OR LOG_ID(\"externalaudit.googleapis.com/activity\") OR LOG_ID(\"cloudaudit.googleapis.com/system_event\") OR LOG_ID(\"externalaudit.googleapis.com/system_event\") OR LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") OR LOG_ID(\"externalaudit.googleapis.com/access_transparency\")\n-protoPayload.serviceName=\"k8s.io\"\n"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | ID of the parent organization. | `string` | n/a | yes |
| <a name="input_policy_source_dir"></a> [policy\_source\_dir](#input\_policy\_source\_dir) | Repository folder where rego policies are stored. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the parent project. Needed for service account IAM bindings. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to place the CloudRun function in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_url"></a> [cloud\_run\_url](#output\_cloud\_run\_url) | URL of the deployed Cloud Run service |
| <a name="output_policy_bucket_name"></a> [policy\_bucket\_name](#output\_policy\_bucket\_name) | Name of the GCS bucket where rego policies are uploaded. |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | Name of the PubSub topic where log messages are consumed. |
<!-- END_TF_DOCS -->
