# =============================================================================
# Secret Outputs
# =============================================================================

output "secret_arn" {
  description = "ARN of the database credentials secret (use this in RDS db_secret_arn)"
  value       = module.database_credentials.secret_arn
}

output "secret_id" {
  description = "ID of the database credentials secret"
  value       = module.database_credentials.secret_id
}

output "secret_name" {
  description = "Name of the database credentials secret"
  value       = module.database_credentials.secret_name
}

output "secret_version_id" {
  description = "Version ID of the database credentials secret"
  value       = module.database_credentials.secret_version_id
}

# =============================================================================
# Credential Values (Sensitive)
# =============================================================================

output "secret_value" {
  description = "The complete secret value (JSON with username and password)"
  value       = module.database_credentials.secret_string
  sensitive   = true
}

output "random_password" {
  description = "The generated random password (same as in the secret)"
  value       = module.database_credentials.random_password
  sensitive   = true
}

# =============================================================================
# Usage Instructions
# =============================================================================

output "usage_instructions" {
  description = "Instructions on how to use this secret with RDS"
  value       = <<-EOT

  ==========================================
  Database Credentials Secret Created!
  ==========================================

  Secret ARN: ${module.database_credentials.secret_arn}
  Secret Name: ${module.database_credentials.secret_name}

  The secret contains:
  {
    "username": "${var.db_username}",
    "password": "<random-32-character-password>"
  }

  HOW TO USE WITH RDS:
  --------------------

  1. Reference this secret ARN in your RDS module:

     module "rds" {
       source = "path/to/terraform-aws-rds/rds"

       databases = {
         main = {
           engine        = "postgres"
           db_secret_arn = "${module.database_credentials.secret_arn}"
           # ... other configuration
         }
       }
     }

  2. RDS will automatically read username and password from the secret

  3. Retrieve the secret value via AWS CLI:

     aws secretsmanager get-secret-value \
       --secret-id ${module.database_credentials.secret_name} \
       --query SecretString --output text | jq .

  4. View the password via Terraform (use with caution):

     terraform output -json random_password | jq -r

  ==========================================
  EOT
}
