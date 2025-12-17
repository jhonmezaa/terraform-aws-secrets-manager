# Multi-Region Replicated Secret Example
provider "aws" {
  region = var.aws_region
}

module "replicated_secret" {
  source = "../../secrets-manager"

  account_name = var.account_name
  project_name = var.project_name

  description = "Multi-region replicated secret"
  secret_string = jsonencode({
    api_key = "global-api-key-123"
    region  = var.aws_region
  })

  # Multi-region replication
  replica = {
    us_west_2 = {
      region = "us-west-2"
    }
    eu_west_1 = {
      region = "eu-west-1"
    }
  }

  # IAM Policy for cross-account access
  create_policy = true
  policy_statements = {
    read_access = {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:role/app-role"]
      }
    }
  }

  recovery_window_in_days = 30
  tags                    = var.tags
}
