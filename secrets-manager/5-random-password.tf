# =============================================================================
# Random Password Generation
# =============================================================================
# Generates ephemeral random passwords that are NOT persisted in Terraform state
# Useful for initial password generation or one-time secret creation

resource "random_password" "this" {
  count = var.create && var.create_random_password ? 1 : 0

  length           = var.random_password_length
  special          = true
  override_special = var.random_password_override_special

  # Ensure at least one of each character type
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}
