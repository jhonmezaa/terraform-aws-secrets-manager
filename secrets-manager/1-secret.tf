# =============================================================================
# AWS Secrets Manager Secret Resource
# =============================================================================
# This file contains the core secret resource with support for:
# - Flexible naming (name vs name_prefix)
# - Multi-region replication
# - KMS encryption
# - Recovery windows
# - Tags

resource "aws_secretsmanager_secret" "this" {
  count = var.create ? 1 : 0

  # Use name_prefix if provided, otherwise use name (or auto-generated name)
  name                           = var.name_prefix == null ? coalesce(var.name, local.secret_name) : null
  name_prefix                    = var.name_prefix
  description                    = var.description
  kms_key_id                     = var.kms_key_id
  recovery_window_in_days        = var.recovery_window_in_days
  force_overwrite_replica_secret = var.force_overwrite_replica_secret

  dynamic "replica" {
    for_each = var.replica != null ? var.replica : {}

    content {
      region     = replica.value.region
      kms_key_id = lookup(replica.value, "kms_key_id", null)
    }
  }

  tags = merge(
    {
      Name      = local.secret_name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}
