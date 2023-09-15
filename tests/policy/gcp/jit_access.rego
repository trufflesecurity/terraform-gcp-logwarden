package jit_access

import future.keywords.in

violation[{"msg": msg, "details": {"project": project, "actor": actor, "role": role, "justification": justification, "start": start, "end": end, "link": link}}] {
    input.protoPayload.labels.event = "api.activateRole"

	project = input.protoPayload.labels.project_id
	role = input.protoPayload.labels.role
    justification = input.protoPayload.labels.justification
    actor = input.protoPayload.labels.user

    start = input.protoPayload.labels.activation_start
    end = input.protoPayload.labels.activation_end

	insertId = input.insertId
	timestamp = input.timestamp
    link = sprintf("https://console.cloud.google.com/logs/query;query=protoPayload.authenticationInfo.principalEmail%3D%22%s%22%0AprotoPayload.@type%3D%22type.googleapis.com%2Fgoogle.cloud.audit.AuditLog%22;startTime=%s;endTime=%s?project=%s", [actor, start, end, project])
	msg = "user has escalated access"
}
