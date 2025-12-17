# =============================================================================
# Rotated Secret Example
# =============================================================================
# This example demonstrates creating a secret with automatic rotation

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Rotated Database Secret
# =============================================================================

module "rotated_secret" {
  source = "../../secrets-manager"

  account_name = var.account_name
  project_name = var.project_name

  description            = "Database password with automatic rotation"
  create_random_password = true
  random_password_length = 32

  # Rotation configuration
  enable_rotation       = true
  rotation_lambda_arn   = var.rotation_lambda_arn
  rotate_immediately    = false
  ignore_secret_changes = true # Lambda manages the value

  rotation_rules = {
    automatically_after_days = 30
    duration                 = "3h"
  }

  recovery_window_in_days = 30

  tags = var.tags
}
