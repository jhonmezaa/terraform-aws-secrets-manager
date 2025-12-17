# =============================================================================
# AWS Secrets Manager Secret Version Resources
# =============================================================================
# This file contains secret version management with two patterns:
# 1. Standard version (for non-rotated secrets)
# 2. Ignore changes version (for Lambda-rotated secrets)

# -----------------------------------------------------------------------------
# Standard Secret Version (Terraform-Managed)
# -----------------------------------------------------------------------------
# Use this when Terraform fully manages the secret value

resource "aws_secretsmanager_secret_version" "this" {
  count = var.create && !var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = local.secret_string
  secret_binary = var.secret_binary

  version_stages = var.version_stages

  depends_on = [aws_secretsmanager_secret_policy.this]
}

# -----------------------------------------------------------------------------
# Ignore Changes Secret Version (Externally-Managed)
# -----------------------------------------------------------------------------
# Use this when Lambda or external processes rotate the secret
# Terraform will not detect drift on secret_string or secret_binary changes

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = var.create && var.ignore_secret_changes ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = local.secret_string
  secret_binary = var.secret_binary

  version_stages = var.version_stages

  lifecycle {
    ignore_changes = [
      secret_string,
      secret_binary,
    ]
  }

  depends_on = [aws_secretsmanager_secret_policy.this]
}
