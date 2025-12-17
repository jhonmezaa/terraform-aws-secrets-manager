variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  type    = string
  default = "prod"
}

variable "project_name" {
  type    = string
  default = "global"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Production"
    Replication = "Enabled"
  }
}
