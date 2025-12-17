# =============================================================================
# Data Sources
# =============================================================================
# External data sources used by the module

# Current AWS region
data "aws_region" "current" {}

# Current AWS caller identity
data "aws_caller_identity" "current" {}
