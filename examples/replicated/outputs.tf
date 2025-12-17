output "secret_arn" {
  value = module.replicated_secret.secret_arn
}

output "secret_name" {
  value = module.replicated_secret.secret_name
}

output "secret_replicas" {
  value       = module.replicated_secret.secret_replica
  description = "Information about replica secrets"
}
