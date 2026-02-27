# =============================================================================
# Local Values
# =============================================================================
# Computed values used throughout the module for naming and logic

locals {
  # -------------------------------------------------------------------------
  # Region Prefix Mapping
  # -------------------------------------------------------------------------
  # Automatic region prefix mapping for consistent resource naming
  region_prefix_map = {
    "us-east-1"      = "ause1"
    "us-east-2"      = "ause2"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
    "af-south-1"     = "afs1"
    "ap-east-1"      = "ape1"
    "ap-south-1"     = "aps1"
    "ap-south-2"     = "aps2"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ca-central-1"   = "cac1"
    "ca-west-1"      = "caw1"
    "eu-central-1"   = "euc1"
    "eu-central-2"   = "euc2"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "eu-south-1"     = "eus1"
    "eu-south-2"     = "eus2"
    "eu-north-1"     = "eun1"
    "il-central-1"   = "ilc1"
    "me-south-1"     = "mes1"
    "me-central-1"   = "mec1"
    "sa-east-1"      = "sae1"
  }

  # -------------------------------------------------------------------------
  # Region Prefix
  # -------------------------------------------------------------------------
  # Use custom region_prefix if provided, otherwise derive from current region
  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.id,
    "custom"
  )

  # Name prefix: conditionally includes region prefix based on use_region_prefix
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # -------------------------------------------------------------------------
  # Secret Naming
  # -------------------------------------------------------------------------
  # Generate secret name for tagging purposes (actual name uses name/name_prefix)
  secret_name = coalesce(
    var.name,
    var.name_prefix != null ? "${var.name_prefix}-secret" : "${local.name_prefix}secret-${var.account_name}-${var.project_name}"
  )

  # -------------------------------------------------------------------------
  # Database Credentials Auto-Generation (Simple - No Circular Dependencies)
  # -------------------------------------------------------------------------
  # Build simple database credentials JSON when db_username is provided with random password
  # Only includes username + password to avoid circular dependency with RDS (RDS endpoint not included)
  db_credentials = var.db_username != null && var.create_random_password && length(random_password.this) > 0 ? {
    username = var.db_username
    password = random_password.this[0].result
  } : null

  # -------------------------------------------------------------------------
  # Secret String Value
  # -------------------------------------------------------------------------
  # Determine which secret value to use (priority order):
  # 1. var.secret_string (explicit string)
  # 2. Auto-generated database credentials JSON (if db_username provided with random password)
  # 3. Simple random password
  # 4. null (will be set by rotation or external process)
  secret_string = var.secret_string != null ? var.secret_string : (
    var.create_random_password && length(random_password.this) > 0 ? (
      local.db_credentials != null ? jsonencode(local.db_credentials) : random_password.this[0].result
    ) : null
  )
}
