# =============================================================================
# General Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "database-creds"
}

# =============================================================================
# Database Configuration
# =============================================================================

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "db_admin"
}

variable "recovery_window_in_days" {
  description = "Number of days to retain secret after deletion (0 for immediate deletion)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (immediate deletion) or between 7 and 30 days"
  }
}

# =============================================================================
# Tags
# =============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Example     = "DatabaseCredentials"
  }
}
