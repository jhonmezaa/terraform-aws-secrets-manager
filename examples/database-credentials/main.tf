# =============================================================================
# Database Credentials Example
# =============================================================================
# This example demonstrates how to create database master credentials with
# auto-generated random password for use with RDS/Aurora instances.
#
# IMPORTANT: Correct Flow to Avoid Circular Dependencies
# -------------------------------------------------------
# 1. Create Secret FIRST (username + random password only)
# 2. Create RDS/Aurora instance SECOND (reference the secret ARN)
# 3. RDS reads username/password from the secret automatically
#
# This avoids circular dependency because:
# - Secret doesn't need RDS endpoint/host (created before RDS exists)
# - RDS references the secret ARN (created after secret exists)
# =============================================================================

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# Database Master Credentials Secret
# -----------------------------------------------------------------------------
# Creates a secret with username and auto-generated random password
# Output: {"username": "db_admin", "password": "random-32-chars"}

module "database_credentials" {
  source = "../../secrets-manager"

  account_name = var.account_name
  project_name = var.project_name

  description = "Database master credentials with auto-generated password"

  # Auto-generate database credentials JSON
  create_random_password = true
  random_password_length = 32
  db_username            = var.db_username # Generates: {"username": "...", "password": "..."}

  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Example: How to Use This Secret with RDS (Commented)
# -----------------------------------------------------------------------------
# After creating the secret above, you can use it with your RDS module:
#
# module "rds" {
#   source = "path/to/terraform-aws-rds/rds"
#
#   databases = {
#     postgres_main = {
#       engine                 = "postgres"
#       engine_version         = "15.4"
#       instance_class         = "db.t3.micro"
#       allocated_storage      = 20
#
#       # Use the secret created above
#       db_secret_arn          = module.database_credentials.secret_arn
#
#       # RDS will automatically read username and password from the secret
#       subnet_ids             = var.database_subnet_ids
#       vpc_security_group_ids = var.vpc_security_group_ids
#
#       publicly_accessible    = false
#       multi_az               = false
#
#       tags = {
#         Environment = "Development"
#       }
#     }
#   }
# }
#
# How it works:
# 1. Secret contains: {"username": "db_admin", "password": "xyz123..."}
# 2. RDS reads the secret using db_secret_arn
# 3. RDS uses username as master_username
# 4. RDS uses password as master_password
# 5. RDS endpoint is available as output (not stored in secret)

# -----------------------------------------------------------------------------
# Alternative: Manual Secret String (Without Auto-Generation)
# -----------------------------------------------------------------------------
# If you don't want auto-generation, you can create credentials manually:
#
# module "database_credentials_manual" {
#   source = "../../secrets-manager"
#
#   account_name = var.account_name
#   project_name = "${var.project_name}-manual"
#
#   description = "Manually created database credentials"
#
#   secret_string = jsonencode({
#     username = "postgres_admin"
#     password = "YourSecurePassword123!" # Not recommended for production
#   })
#
#   recovery_window_in_days = 30
#
#   tags = var.tags
# }
