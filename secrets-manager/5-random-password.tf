# =============================================================================
# Random Password Generation
# =============================================================================
# Generates a random password with the random_password resource.
# NOTE: the result IS stored in Terraform state (use an encrypted remote backend).

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
