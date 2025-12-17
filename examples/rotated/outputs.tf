# =============================================================================
# Outputs
# =============================================================================

output "secret_arn" {
  description = "The ARN of the secret"
  value       = module.rotated_secret.secret_arn
}

output "secret_name" {
  description = "The name of the secret"
  value       = module.rotated_secret.secret_name
}

output "rotation_enabled" {
  description = "Whether rotation is enabled"
  value       = module.rotated_secret.secret_rotation_enabled
}
