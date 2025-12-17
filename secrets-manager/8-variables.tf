# =============================================================================
# Variables
# =============================================================================

# =============================================================================
# General Configuration
# =============================================================================

variable "create" {
  description = "Whether to create all resources (master toggle)"
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Secret Configuration
# =============================================================================

variable "name" {
  description = "Friendly name for the secret. Mutually exclusive with name_prefix. Allowed characters: alphanumeric, /_+=.@-"
  type        = string
  default     = null

  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z0-9/_+=.@-]+$", var.name))
    error_message = "Secret name must contain only alphanumeric characters and /_+=.@-"
  }
}

variable "name_prefix" {
  description = "Creates a unique secret name beginning with the specified prefix. Mutually exclusive with name. Terraform will auto-generate a suffix"
  type        = string
  default     = null

  validation {
    condition     = var.name_prefix == null || can(regex("^[a-zA-Z0-9/_+=.@-]+$", var.name_prefix))
    error_message = "Secret name prefix must contain only alphanumeric characters and /_+=.@-"
  }
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ARN or ID of the AWS KMS key to encrypt the secret. If not specified, uses the AWS managed key aws/secretsmanager"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days to retain secret after deletion (0 for immediate, 7-30 for recovery window). Defaults to 30 days if not specified"
  type        = number
  default     = null

  validation {
    condition     = var.recovery_window_in_days == null || (var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30))
    error_message = "Recovery window must be 0 (immediate deletion) or between 7 and 30 days"
  }
}

variable "force_overwrite_replica_secret" {
  description = "Whether to overwrite a secret with the same name in the destination region. Only applies when creating replicas"
  type        = bool
  default     = false
}

# =============================================================================
# Secret Value Storage
# =============================================================================

variable "secret_string" {
  description = "Plaintext string or JSON-formatted secret data. Stored in Terraform state. Mutually exclusive with secret_binary"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_binary" {
  description = "Base64-encoded binary secret data. Stored in Terraform state. Mutually exclusive with secret_string"
  type        = string
  default     = null
  sensitive   = true
}

variable "version_stages" {
  description = "List of staging labels attached to the secret version (e.g., ['AWSCURRENT', 'MYSTAGE'])"
  type        = list(string)
  default     = null
}

variable "ignore_secret_changes" {
  description = "Whether to ignore external changes to secret content (useful for Lambda-rotated secrets). WARNING: Changes to this value will recreate the secret version"
  type        = bool
  default     = false
}

# =============================================================================
# Multi-Region Replication
# =============================================================================

variable "replica" {
  description = <<-EOT
    Map of replica configurations for multi-region secret replication. Each key is a friendly name, value is an object with:
    - region: AWS region to replicate to (required)
    - kms_key_id: KMS key ARN/ID for encryption in that region (optional, defaults to AWS managed key)

    Example:
    replica = {
      us_west_2 = {
        region     = "us-west-2"
        kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/abc-123"
      }
      eu_west_1 = {
        region = "eu-west-1"
      }
    }
  EOT
  type = map(object({
    region     = string
    kms_key_id = optional(string)
  }))
  default = null
}

# =============================================================================
# Random Password Generation
# =============================================================================

variable "create_random_password" {
  description = "Whether to generate a random password for the secret. Password is ephemeral and not stored in Terraform state"
  type        = bool
  default     = false
}

variable "random_password_length" {
  description = "Length of the generated random password (if create_random_password is true)"
  type        = number
  default     = 32

  validation {
    condition     = var.random_password_length >= 8 && var.random_password_length <= 256
    error_message = "Password length must be between 8 and 256 characters"
  }
}

variable "random_password_override_special" {
  description = "Override the default special characters used in random password generation"
  type        = string
  default     = "!@#$%&*()-_=+[]{}<>:?"
}

# =============================================================================
# Database Credentials (Simple JSON with Random Password)
# =============================================================================

variable "db_username" {
  description = <<-EOT
    Database username. When provided along with create_random_password=true, the module will automatically
    generate a simple JSON secret with username and random password (no host/endpoint to avoid circular dependencies).
    Example output: {"username": "admin", "password": "random-password"}
  EOT
  type        = string
  default     = null
}

# =============================================================================
# Resource Policy Configuration
# =============================================================================

variable "create_policy" {
  description = "Whether to create and attach a resource-based IAM policy to the secret"
  type        = bool
  default     = false
}

variable "source_policy_documents" {
  description = "List of IAM policy documents (JSON strings) to merge together as the base policy"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents (JSON strings) that override statements with matching SIDs in source policies"
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = <<-EOT
    Map of custom IAM policy statements to attach to the secret. Each key is a statement identifier, value is an object with:
    - sid: Statement ID (optional, defaults to key)
    - effect: Allow or Deny (optional, defaults to Allow)
    - actions: List of allowed/denied actions (e.g., ["secretsmanager:GetSecretValue"])
    - not_actions: List of excluded actions
    - resources: List of resource ARNs (defaults to ["*"] for the secret itself)
    - not_resources: List of excluded resources
    - principals: Object with 'type' and 'identifiers' (e.g., {type = "AWS", identifiers = ["arn:aws:iam::123:role/MyRole"]})
    - not_principals: Excluded principals
    - conditions: Map of condition blocks with 'test', 'variable', and 'values'

    Example:
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
  EOT
  type = map(object({
    sid           = optional(string)
    effect        = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    not_principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    conditions = optional(map(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "block_public_policy" {
  description = "Whether to block resource-based policies that grant public access to the secret"
  type        = bool
  default     = true
}

# =============================================================================
# Secret Rotation Configuration
# =============================================================================

variable "enable_rotation" {
  description = "Whether to enable automatic secret rotation using AWS Lambda"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function that handles secret rotation. Required if enable_rotation is true"
  type        = string
  default     = null

  validation {
    condition     = var.rotation_lambda_arn == null || can(regex("^arn:aws:lambda:", var.rotation_lambda_arn))
    error_message = "rotation_lambda_arn must be a valid Lambda ARN"
  }
}

variable "rotate_immediately" {
  description = "Whether to rotate the secret immediately upon creation (true) or wait for the first scheduled rotation (false/null)"
  type        = bool
  default     = null
}

variable "rotation_rules" {
  description = <<-EOT
    Configuration for secret rotation schedule. Object with:
    - automatically_after_days: Rotate every N days (e.g., 30)
    - schedule_expression: Cron or rate expression (e.g., "cron(0 2 * * ? *)" or "rate(30 days)")
    - duration: Length of rotation window (e.g., "3h" or "PT3H")

    Note: Use either automatically_after_days OR schedule_expression, not both

    Example:
    rotation_rules = {
      automatically_after_days = 30
      duration                 = "3h"
    }
  EOT
  type = object({
    automatically_after_days = optional(number)
    schedule_expression      = optional(string)
    duration                 = optional(string)
  })
  default = null

  validation {
    condition = var.rotation_rules == null || (
      # If rotation_rules is set, at least one of automatically_after_days or schedule_expression must be set
      try(var.rotation_rules.automatically_after_days, null) != null ||
      try(var.rotation_rules.schedule_expression, null) != null
    )
    error_message = "rotation_rules must specify either automatically_after_days or schedule_expression"
  }
}
