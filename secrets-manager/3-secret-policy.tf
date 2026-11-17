# =============================================================================
# AWS Secrets Manager Secret Policy
# =============================================================================
# This file handles IAM resource policies for secret access control with:
# - Custom policy statements with principals, actions, conditions
# - Source and override policy document merging
# - Public access blocking validation

# -----------------------------------------------------------------------------
# IAM Policy Document Data Source
# -----------------------------------------------------------------------------
# Merges multiple policy sources with SID-based override support

data "aws_iam_policy_document" "this" {
  count = var.create && var.create_policy ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.policy_statements != null ? var.policy_statements : {}

    content {
      sid         = statement.value.sid
      effect      = coalesce(statement.value.effect, "Allow")
      actions     = statement.value.actions
      not_actions = statement.value.not_actions
      # Default to the secret ARN, unless not_resources is used (both are mutually exclusive in IAM)
      resources     = statement.value.not_resources != null ? statement.value.resources : coalesce(statement.value.resources, [aws_secretsmanager_secret.this[0].arn])
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? [statement.value.principals] : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? [statement.value.not_principals] : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : {}

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Secret Resource Policy
# -----------------------------------------------------------------------------
# Attaches the IAM policy document to the secret

resource "aws_secretsmanager_secret_policy" "this" {
  count = var.create && var.create_policy ? 1 : 0

  region = var.region

  secret_arn          = aws_secretsmanager_secret.this[0].arn
  policy              = data.aws_iam_policy_document.this[0].json
  block_public_policy = var.block_public_policy
}
