# Changelog

## [v1.0.3] - 2026-02-27

### Changed
- Standardize Terraform `required_version` to `~> 1.0` across module and examples


## [v1.0.2] - 2026-02-27

### Changed
- Update AWS provider constraint to `~> 6.0` across module and examples


All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-01-07

### Fixed

#### IAM Policy Conditions Handling
- Improved handling of optional conditions in IAM policy statements (`secrets-manager/3-secret-policy.tf`)
- Changed from `try(statement.value.conditions, {})` to `coalesce(lookup(statement.value, "conditions", null), {})`
- More robust handling of missing or null conditions attribute
- Prevents potential issues with policy document generation when conditions are not provided

### Technical Details

**What Changed:**
- The dynamic `condition` block in `aws_iam_policy_document` now uses `coalesce(lookup())` pattern
- This ensures consistent behavior when the `conditions` attribute is:
  - Not present in the statement
  - Explicitly set to `null`
  - Set to an empty map `{}`

**Impact:**
- More predictable behavior for policy creation
- Better alignment with Terraform best practices
- No breaking changes - fully backward compatible

## [1.0.0] - 2024-12-16

### 🎉 Initial Release

First production-ready release of the AWS Secrets Manager Terraform module with comprehensive secret management capabilities.

### Added

#### Core Secret Management
- Secret creation with flexible naming (name vs name_prefix)
- Description and metadata support
- Support for string and binary secrets
- Automatic region prefix generation for resource naming
- Consistent resource naming convention across all resources

#### Multi-Region Replication
- Deploy secrets across multiple AWS regions
- Per-region KMS encryption key configuration
- Force overwrite capability for same-named secrets in target regions
- Automatic synchronization of secret value changes

#### Secret Rotation
- Lambda function integration for custom rotation logic
- Automatic rotation scheduling with flexible rules
- Frequency-based rotation (every N days)
- Cron-based rotation (specific time/day)
- Rate-based rotation expressions
- Immediate rotation triggering option
- Structured secrets support (JSON database credentials)

#### Random Password Generation
- Ephemeral password generation (not persisted in state)
- Configurable password length (8-256 characters, default 32)
- Custom special character sets
- Automatic integration with secret storage
- Minimum character type requirements

#### Encryption & Security
- AWS KMS key support for encryption at rest
- Custom KMS key per region (including replicas)
- Defaults to AWS managed key (aws/secretsmanager) when not specified
- Encryption for all secret values and metadata

#### Access Control & Policies
- Resource-based IAM policy attachment
- Custom policy statements with principals, actions, resources
- Condition-based access controls (IP, time, etc.)
- Public access blocking validation
- Policy document merging (source + override patterns)
- Cross-account access support
- Statement ID (SID) based override capability

#### Deletion & Recovery
- Configurable recovery window (0 or 7-30 days)
- 0-day window for immediate deletion (dev/test)
- Grace period for production data protection
- Soft delete with recovery capability

#### Version Management
- Staging labels for secret versions
- Support for external secret changes
- Ignore-changes lifecycle for rotation scenarios
- Version tracking and history

#### Conditional Creation
- Master `create` toggle for all resources
- Ephemeral resources for write-only values
- Lifecycle management for rotation-enabled secrets

### Features

#### Numbered File Structure
Module organized with clear 0-9 numbered files:
- `0-versions.tf` - Terraform and provider requirements
- `1-secret.tf` - Core secret resource
- `2-secret-version.tf` - Version management (standard + ignore_changes)
- `3-secret-policy.tf` - IAM policies
- `4-secret-rotation.tf` - Rotation configuration
- `5-random-password.tf` - Password generation
- `6-locals.tf` - Local values and naming logic
- `7-data.tf` - Data sources
- `8-variables.tf` - All input variables (70+)
- `9-outputs.tf` - All outputs (11)

#### Outputs (11 total)
- Secret attributes (ARN, ID, name)
- Secret replica information
- Version identifiers
- Secret values (sensitive)
- Rotation status and Lambda ARN
- Policy documents
- Generated passwords (sensitive)

#### Examples
Four complete examples with full documentation:
- **basic**: Simple secret with static value and recovery window
- **database-credentials**: Database credentials with auto-generated random password for RDS/Aurora (avoids circular dependencies)
- **rotated**: Secret with Lambda rotation and random password generation
- **replicated**: Multi-region secret with IAM policies and replication

Each example includes:
- `versions.tf` - Version constraints
- `variables.tf` - Configurable parameters
- `main.tf` - Module usage
- `outputs.tf` - Output values
- `README.md` - Usage documentation
- `terraform.tfvars.example` - Example values

#### Documentation
- Comprehensive README (425+ lines) with:
  - Complete usage examples for all features
  - Input variables reference table
  - Output values reference table
  - Region prefix mapping
  - Rotation configuration patterns
  - Best practices guide
  - Security recommendations
  - Cost optimization tips
- CHANGELOG with release notes
- terraform.tfvars.example for all examples
- README for each example

#### Code Quality
- Terraform >= 1.5.0 compatibility
- AWS Provider >= 5.0 compatibility
- Random Provider >= 3.6 compatibility
- Numbered file organization (0-9)
- Consistent code formatting
- Comprehensive variable validation
- Terraform validate passing for module and all examples
- Dynamic blocks for optional features
- Conditional resource creation patterns

### Technical Details

#### Supported Regions
- All AWS commercial regions (25+)
- Automatic region prefix mapping
- Custom region prefix override support

#### Resource Types
- `aws_secretsmanager_secret` - Core secret resource
- `aws_secretsmanager_secret_version` - Version management (2 patterns)
- `aws_secretsmanager_secret_policy` - IAM policies
- `aws_secretsmanager_secret_rotation` - Rotation configuration
- `random_password` - Ephemeral password generation

#### Performance
- Efficient use of conditional creation
- Minimal resource dependencies
- Optimized data source queries
- Lazy evaluation of optional resources
- Dynamic blocks for scalability

#### Compatibility
- Terraform >= 1.5.0
- AWS Provider >= 5.0
- Random Provider >= 3.6
- Compatible with Terraform Cloud
- Compatible with Terragrunt
- Module composition ready

### Dependencies

#### Required Providers
- hashicorp/aws >= 5.0
- hashicorp/random >= 3.6

#### Terraform Version
- terraform >= 1.5.0

### Notes

- This is the first stable release (1.0.0)
- All features are production-ready
- Breaking changes will follow semantic versioning
- See examples for recommended usage patterns
- Secrets are stored in Terraform state (use remote state with encryption)

### Migration Notes

This is the first release - no migration needed.

### Known Issues

None reported in this release.

### Contributors

- Initial implementation and release

---

## Release Checklist

- [x] All examples validated with `terraform validate`
- [x] README.md documentation complete
- [x] CHANGELOG.md created
- [x] All input variables documented
- [x] All outputs documented
- [x] Code formatted with `terraform fmt`
- [x] Examples cover all major use cases
- [x] Naming conventions consistent
- [x] Security best practices implemented
- [x] terraform.tfvars.example added to all examples
- [x] README.md added to each example

[1.0.0]: https://github.com/jhonmezaa/terraform-aws-secrets-manager/releases/tag/v1.0.0
