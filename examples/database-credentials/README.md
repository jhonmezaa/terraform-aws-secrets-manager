# Database Credentials Example

This example demonstrates how to create database master credentials with auto-generated random password for use with RDS/Aurora instances.

## Features

- **Auto-Generated Password**: Creates a 32-character random password automatically
- **Simple JSON Structure**: Contains only username and password (no host/endpoint)
- **No Circular Dependencies**: Secret created BEFORE RDS instance
- **RDS Integration**: Secret ARN can be passed to RDS module

## Problem: Circular Dependency

When creating database secrets for RDS, you might encounter a circular dependency:

```
❌ WRONG APPROACH:
RDS → needs → Secret ARN (for credentials)
  ↓
Secret → needs → RDS endpoint (db_host)
  ↓
RDS → needs → Secret... (circular!)
```

## Solution: Create Secret First

This example follows the correct pattern:

```
✅ CORRECT APPROACH:
1. Create Secret (username + password only)
2. Create RDS (use secret ARN)
3. RDS reads credentials from secret
4. RDS endpoint available as output (not in secret)
```

## Secret Structure

The module auto-generates a simple JSON structure:

```json
{
  "username": "db_admin",
  "password": "aB3!xYz...32-random-characters..."
}
```

**Note**: The secret intentionally does NOT include:
- `host` / `endpoint` (RDS endpoint)
- `port` (database port)
- `dbname` (database name)
- `engine` (database engine)

These values are available from RDS outputs after creation and should not be in the secret to avoid circular dependencies.

## Usage

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. View Outputs

```bash
# View secret ARN (needed for RDS)
terraform output secret_arn

# View secret name
terraform output secret_name

# View the password (sensitive)
terraform output -json random_password | jq -r

# View complete secret value (sensitive)
terraform output -json secret_value | jq -r | jq .
```

### 4. Use with RDS Module

After creating the secret, use it in your RDS configuration:

```hcl
module "rds" {
  source = "path/to/terraform-aws-rds/rds"

  databases = {
    postgres_main = {
      engine                 = "postgres"
      engine_version         = "15.4"
      instance_class         = "db.t3.micro"

      # Reference the secret created above
      db_secret_arn          = module.database_credentials.secret_arn

      # RDS automatically reads username/password from secret
      subnet_ids             = var.database_subnet_ids
      vpc_security_group_ids = var.vpc_security_group_ids

      publicly_accessible    = false
      multi_az               = false
    }
  }
}

# Access RDS endpoint from outputs
output "database_endpoint" {
  value = module.rds.db_instance_endpoint["postgres_main"]
}
```

## Retrieve Secret Value via AWS CLI

```bash
# Get secret value
SECRET_NAME=$(terraform output -raw secret_name)
aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --query SecretString --output text | jq .

# Expected output:
# {
#   "username": "db_admin",
#   "password": "aB3!xYz..."
# }
```

## How RDS Uses the Secret

When you provide `db_secret_arn` to the RDS module:

1. **RDS reads the secret** during creation
2. **Extracts username** from `secret.username`
3. **Extracts password** from `secret.password`
4. **Creates database** with these credentials
5. **RDS endpoint** becomes available as an output

Your application can then:
- Get credentials from Secrets Manager (username + password)
- Get endpoint from RDS outputs (host + port)
- Connect to the database

## Best Practices

### For Production

```hcl
recovery_window_in_days = 30  # Allow 30-day recovery period
```

### For Development/Testing

```hcl
recovery_window_in_days = 0   # Immediate deletion (no recovery)
```

### Password Configuration

The default configuration generates strong passwords:
- **Length**: 32 characters
- **Character types**: Uppercase, lowercase, numbers, special characters
- **Special characters**: `!@#$%&*()-_=+[]{}<>:?`

You can customize in the module call:

```hcl
module "database_credentials" {
  source = "../../secrets-manager"

  create_random_password           = true
  random_password_length           = 64  # Custom length
  random_password_override_special = "!@#$%^&*()"  # Custom special chars
  db_username                      = "postgres_admin"

  # ... other configuration
}
```

## Security Considerations

1. **Terraform State**: Secret values are stored in Terraform state
   - Use remote state with encryption (S3 + KMS)
   - Restrict access to state files
   - Use state locking

2. **Secret Access**: Use IAM policies to restrict who can read the secret
   ```hcl
   create_policy = true
   policy_statements = {
     app_access = {
       actions = ["secretsmanager:GetSecretValue"]
       principals = {
         type = "AWS"
         identifiers = ["arn:aws:iam::123456789012:role/app-role"]
       }
     }
   }
   ```

3. **Rotation**: Consider enabling rotation after RDS is created
   - Create Lambda rotation function
   - Update secret with `enable_rotation = true`
   - Use `ignore_secret_changes = true` for rotated secrets

## Example Output

After applying, you'll see:

```
secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:ause1-secret-dev-database-creds-AbCdEf"
secret_name = "ause1-secret-dev-database-creds"

usage_instructions = <<-EOT
  ==========================================
  Database Credentials Secret Created!
  ==========================================

  Secret ARN: arn:aws:secretsmanager:us-east-1:123456789012:secret:...
  Secret Name: ause1-secret-dev-database-creds

  The secret contains:
  {
    "username": "db_admin",
    "password": "<random-32-character-password>"
  }

  HOW TO USE WITH RDS:
  --------------------
  [Instructions for using with RDS module]
EOT
```

## Files

- `versions.tf` - Terraform and provider version requirements
- `variables.tf` - Input variables with defaults and validation
- `main.tf` - Secret creation with auto-generated credentials
- `outputs.tf` - Secret ARN, name, and usage instructions
- `terraform.tfvars.example` - Example configuration values
- `README.md` - This file

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |
| random | >= 3.6 |

## Cleanup

```bash
# Destroy the secret
terraform destroy

# Force delete without recovery (if recovery window > 0)
SECRET_ARN=$(terraform output -raw secret_arn)
aws secretsmanager delete-secret \
  --secret-id $SECRET_ARN \
  --force-delete-without-recovery
```

## Related Examples

- [basic](../basic) - Simple secret with static value
- [rotated](../rotated) - Secret with Lambda rotation
- [replicated](../replicated) - Multi-region secret with IAM policies
