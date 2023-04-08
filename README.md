# terraform-gcp-auditor
Terraform module for the GCP auditor

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.auditor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_logging_organization_sink.audit-logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_pubsub_subscription.gcp-auditor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription.gcp-auditor-test](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.audit-logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_policy.sink_topic_iam_poicy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_policy) | resource |
| [google_iam_policy.sink_topic_iam_policy_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image for the auditor tool. Used by Cloud Run | `string` | n/a | yes |
| <a name="input_logging_sink_filter"></a> [logging\_sink\_filter](#input\_logging\_sink\_filter) | n/a | `string` | `"LOG_ID(\"cloudaudit.googleapis.com/activity\") OR LOG_ID(\"externalaudit.googleapis.com/activity\") OR LOG_ID(\"cloudaudit.googleapis.com/system_event\") OR LOG_ID(\"externalaudit.googleapis.com/system_event\") OR LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") OR LOG_ID(\"externalaudit.googleapis.com/access_transparency\")\n-protoPayload.serviceName=\"k8s.io\"\n"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of app, service, or context using this module. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | ID of the parent organization. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the parent project. Needed for service account IAM bindings. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to place the CloudRun function in. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->