# =============================================================================
# Outputs
# =============================================================================

output "secret_arn" {
  description = "The ARN of the secret"
  value       = module.basic_secret.secret_arn
}

output "secret_name" {
  description = "The name of the secret"
  value       = module.basic_secret.secret_name
}

output "secret_version_id" {
  description = "The version ID of the secret"
  value       = module.basic_secret.secret_version_id
}
