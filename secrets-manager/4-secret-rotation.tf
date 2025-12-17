# =============================================================================
# AWS Secrets Manager Secret Rotation
# =============================================================================
# This file handles automatic secret rotation with Lambda functions
# Supports flexible scheduling: frequency-based or cron expressions

resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.create && var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this[0].id
  rotation_lambda_arn = var.rotation_lambda_arn

  # Rotate immediately on creation (true) or wait for schedule (false/null)
  rotate_immediately = var.rotate_immediately

  rotation_rules {
    # Frequency-based: Rotate every N days
    automatically_after_days = lookup(var.rotation_rules, "automatically_after_days", null)

    # Cron-based: Specific time/day (e.g., "cron(0 2 * * ? *)")
    # OR rate-based: (e.g., "rate(30 days)")
    schedule_expression = lookup(var.rotation_rules, "schedule_expression", null)

    # Duration of rotation window (e.g., "3h", "PT3H")
    duration = lookup(var.rotation_rules, "duration", null)
  }

  depends_on = [
    aws_secretsmanager_secret_version.this,
    aws_secretsmanager_secret_version.ignore_changes,
  ]
}
