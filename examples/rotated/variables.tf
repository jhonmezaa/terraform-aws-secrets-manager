# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "database"
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function for rotation (must be pre-created)"
  type        = string
  default     = "arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Rotation    = "Enabled"
  }
}
