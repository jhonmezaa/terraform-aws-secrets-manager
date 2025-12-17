# =============================================================================
# Basic Secrets Manager Example
# =============================================================================
# This example demonstrates creating a basic secret with:
# - Static secret value
# - Standard recovery window
# - Simple configuration

provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Basic Secret
# =============================================================================

module "basic_secret" {
  source = "../../secrets-manager"

  account_name = var.account_name
  project_name = var.project_name

  description = "Basic API key secret"
  secret_string = jsonencode({
    api_key = var.secret_value
    created = timestamp()
  })

  recovery_window_in_days = 30

  tags = var.tags
}
