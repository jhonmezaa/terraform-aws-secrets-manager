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
      sid           = lookup(statement.value, "sid", statement.key)
      effect        = lookup(statement.value, "effect", "Allow")
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", ["*"])
      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", null) != null ? [statement.value.principals] : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", null) != null ? [statement.value.not_principals] : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, {})

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

  secret_arn          = aws_secretsmanager_secret.this[0].arn
  policy              = data.aws_iam_policy_document.this[0].json
  block_public_policy = var.block_public_policy
}
