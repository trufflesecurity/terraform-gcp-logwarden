docker_image      = "us-docker.pkg.dev/thog-artifacts/public/logwarden:latest"
filter            = <<EOF
LOG_ID("cloudaudit.googleapis.com/activity") OR LOG_ID("externalaudit.googleapis.com/activity") OR LOG_ID("cloudaudit.googleapis.com/system_event") OR LOG_ID("externalaudit.googleapis.com/system_event") OR LOG_ID("cloudaudit.googleapis.com/access_transparency") OR LOG_ID("externalaudit.googleapis.com/access_transparency")
-protoPayload.serviceName="k8s.io"
EOF
ingress           = "INGRESS_TRAFFIC_INTERNAL_ONLY"
config_secret_id  = "test-environment-app-secrets"
container_args    = []
policy_source_dir = "../../tests/policy/gcp"
