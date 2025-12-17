# =============================================================================
# Outputs
# =============================================================================

# =============================================================================
# Secret Outputs
# =============================================================================

output "secret_arn" {
  description = "The ARN of the secret"
  value       = try(aws_secretsmanager_secret.this[0].arn, null)
}

output "secret_id" {
  description = "The ID of the secret (same as ARN)"
  value       = try(aws_secretsmanager_secret.this[0].id, null)
}

output "secret_name" {
  description = "The name of the secret"
  value       = try(aws_secretsmanager_secret.this[0].name, null)
}

output "secret_replica" {
  description = "Attributes of replicas created for multi-region secrets"
  value       = try(aws_secretsmanager_secret.this[0].replica, null)
}

# =============================================================================
# Secret Version Outputs
# =============================================================================

output "secret_version_id" {
  description = "The unique identifier of the version of the secret"
  value = try(
    coalesce(
      try(aws_secretsmanager_secret_version.this[0].version_id, null),
      try(aws_secretsmanager_secret_version.ignore_changes[0].version_id, null)
    ),
    null
  )
}

output "secret_string" {
  description = "The decrypted secret string (sensitive)"
  sensitive   = true
  value = try(
    coalesce(
      try(aws_secretsmanager_secret_version.this[0].secret_string, null),
      try(aws_secretsmanager_secret_version.ignore_changes[0].secret_string, null)
    ),
    null
  )
}

output "secret_binary" {
  description = "The decrypted secret binary data (sensitive)"
  sensitive   = true
  value = try(
    coalesce(
      try(aws_secretsmanager_secret_version.this[0].secret_binary, null),
      try(aws_secretsmanager_secret_version.ignore_changes[0].secret_binary, null)
    ),
    null
  )
}

# =============================================================================
# Rotation Outputs
# =============================================================================

output "secret_rotation_enabled" {
  description = "Whether automatic rotation is enabled for the secret"
  value       = try(aws_secretsmanager_secret_rotation.this[0].rotation_enabled, false)
}

output "secret_rotation_lambda_arn" {
  description = "The ARN of the Lambda function handling rotation"
  value       = try(aws_secretsmanager_secret_rotation.this[0].rotation_lambda_arn, null)
}

# =============================================================================
# Policy Outputs
# =============================================================================

output "secret_policy" {
  description = "The resource-based IAM policy attached to the secret"
  value       = try(aws_secretsmanager_secret_policy.this[0].policy, null)
}

# =============================================================================
# Random Password Output
# =============================================================================

output "random_password" {
  description = "The generated random password (if create_random_password was true). Sensitive output"
  sensitive   = true
  value       = try(random_password.this[0].result, null)
}
