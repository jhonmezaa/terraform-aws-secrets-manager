# =============================================================================
# AWS Secrets Manager Secret Rotation
# =============================================================================
# This file handles automatic secret rotation with Lambda functions
# Supports flexible scheduling: frequency-based or cron expressions

resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.create && var.enable_rotation ? 1 : 0

  region = var.region

  secret_id           = aws_secretsmanager_secret.this[0].id
  rotation_lambda_arn = var.rotation_lambda_arn

  # Rotate immediately on creation (true) or wait for schedule (false/null)
  rotate_immediately = var.rotate_immediately

  # Only rendered when rotation_rules is set (the block is optional in the provider)
  dynamic "rotation_rules" {
    for_each = var.rotation_rules != null ? [var.rotation_rules] : []

    content {
      # Frequency-based: Rotate every N days
      automatically_after_days = rotation_rules.value.automatically_after_days

      # Cron-based: Specific time/day (e.g., "cron(0 2 * * ? *)")
      # OR rate-based: (e.g., "rate(30 days)")
      schedule_expression = rotation_rules.value.schedule_expression

      # Duration of rotation window (e.g., "3h", "PT3H")
      duration = rotation_rules.value.duration
    }
  }

  depends_on = [
    aws_secretsmanager_secret_version.this,
    aws_secretsmanager_secret_version.ignore_changes,
  ]
}
