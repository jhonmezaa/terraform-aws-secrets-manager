# Terraform AWS Secrets Manager Module

Production-ready Terraform module for creating and managing AWS Secrets Manager secrets with comprehensive features including multi-region replication, automatic rotation, random password generation, and IAM policies.

## Features

- **Secret Creation & Management**: Flexible naming (name vs name_prefix), descriptions, and metadata
- **Multi-Region Replication**: Deploy secrets across multiple AWS regions with per-region KMS encryption
- **Secret Rotation**: Automatic rotation using AWS Lambda with flexible scheduling (frequency or cron-based)
- **Random Password Generation**: Ephemeral password generation that isn't persisted in Terraform state
- **KMS Encryption**: Custom KMS key support for encryption at rest
- **Resource Policies**: IAM policies with principals, actions, conditions, and cross-account access
- **Version Management**: Staging labels and lifecycle management for rotated secrets
- **Recovery Windows**: Configurable deletion recovery (0-30 days)
- **Conditional Creation**: Master toggle for all resources
- **Region Prefix Mapping**: Automatic naming conventions across 25+ AWS regions

## Usage

### Basic Secret

```hcl
module "basic_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "myapp"

  description   = "API key for MyApp"
  secret_string = jsonencode({
    api_key = "sk-1234567890abcdef"
  })

  recovery_window_in_days = 30

  tags = {
    Environment = "Production"
  }
}
```

### Secret with Random Password

```hcl
module "password_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "database"

  description            = "Database password"
  create_random_password = true
  random_password_length = 32

  recovery_window_in_days = 30

  tags = {
    Environment = "Production"
    Database    = "PostgreSQL"
  }
}
```

### Secret with Automatic Rotation

```hcl
module "rotated_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "rds"

  description            = "RDS master password with rotation"
  create_random_password = true
  random_password_length = 64

  # Rotation configuration
  enable_rotation       = true
  rotation_lambda_arn   = aws_lambda_function.rotation.arn
  rotate_immediately    = false
  ignore_secret_changes = true  # Lambda manages the value

  rotation_rules = {
    automatically_after_days = 30
    duration                 = "3h"
  }

  recovery_window_in_days = 30

  tags = {
    Environment = "Production"
    Rotation    = "Enabled"
  }
}
```

### Multi-Region Replicated Secret

```hcl
module "global_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "global-api"

  description   = "Global API key replicated across regions"
  secret_string = var.api_key

  # Multi-region replication
  replica = {
    us_west_2 = {
      region     = "us-west-2"
      kms_key_id = aws_kms_key.us_west_2.arn
    }
    eu_west_1 = {
      region     = "eu-west-1"
      kms_key_id = aws_kms_key.eu_west_1.arn
    }
  }

  recovery_window_in_days = 30

  tags = {
    Environment = "Production"
    Replication = "Enabled"
  }
}
```

### Secret with IAM Policy

```hcl
module "policy_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "shared"

  description   = "Shared secret with IAM policy"
  secret_string = var.secret_value

  # Create resource policy
  create_policy = true
  policy_statements = {
    app_access = {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      principals = {
        type        = "AWS"
        identifiers = [
          "arn:aws:iam::123456789012:role/app-role",
          "arn:aws:iam::123456789012:role/lambda-role"
        ]
      }
    }
    deny_delete = {
      effect  = "Deny"
      actions = ["secretsmanager:DeleteSecret"]
      principals = {
        type        = "AWS"
        identifiers = ["*"]
      }
    }
  }

  block_public_policy = true

  tags = {
    Environment = "Production"
    Access      = "Restricted"
  }
}
```

### Secret with Conditions

```hcl
module "conditional_secret" {
  source = "github.com/jhonmezaa/terraform-aws-secrets-manager//secrets-manager?ref=v1.0.0"

  account_name = "prod"
  project_name = "restricted"

  description   = "Secret with IP-restricted access"
  secret_string = var.secret_value

  create_policy = true
  policy_statements = {
    ip_restricted = {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:role/app"]
      }
      conditions = {
        ip_restriction = {
          test     = "IpAddress"
          variable = "aws:SourceIp"
          values   = ["10.0.0.0/8", "172.16.0.0/12"]
        }
      }
    }
  }

  tags = {
    Environment = "Production"
    Security    = "IP-Restricted"
  }
}
```

## Examples

Four complete examples are provided:

1. **[basic](./examples/basic)** - Simple secret with static value
2. **[database-credentials](./examples/database-credentials)** - Database credentials with auto-generated random password (for RDS/Aurora)
3. **[rotated](./examples/rotated)** - Secret with Lambda rotation and random password
4. **[replicated](./examples/replicated)** - Multi-region secret with IAM policy

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.5.0 |
| aws       | >= 5.0   |
| random    | >= 3.6   |

## Providers

| Name   | Version |
| ------ | ------- |
| aws    | >= 5.0  |
| random | >= 3.6  |

## Resources

| Type                                                                                                                                             | Name           |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)                   | this           |
| [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)   | this           |
| [aws_secretsmanager_secret_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version)   | ignore_changes |
| [aws_secretsmanager_secret_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy)     | this           |
| [aws_secretsmanager_secret_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | this           |
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                       | this           |

## Inputs

### General Configuration

| Name              | Description                                             | Type          | Default | Required |
| ----------------- | ------------------------------------------------------- | ------------- | ------- | :------: |
| create            | Whether to create all resources (master toggle)         | `bool`        | `true`  |    no    |
| account_name      | Account name for resource naming                        | `string`      | n/a     |   yes    |
| project_name      | Project name for resource naming                        | `string`      | n/a     |   yes    |
| region_prefix     | Region prefix for naming (auto-derived if not provided) | `string`      | `null`  |    no    |
| use_region_prefix | Whether to include the region prefix in resource names  | `bool`        | `true`  |    no    |
| tags              | Additional tags to apply to all resources               | `map(string)` | `{}`    |    no    |

### Secret Configuration

| Name                           | Description                                                        | Type     | Default | Required |
| ------------------------------ | ------------------------------------------------------------------ | -------- | ------- | :------: |
| name                           | Friendly name for the secret (mutually exclusive with name_prefix) | `string` | `null`  |    no    |
| name_prefix                    | Creates unique name with prefix (mutually exclusive with name)     | `string` | `null`  |    no    |
| description                    | Description of the secret                                          | `string` | `null`  |    no    |
| kms_key_id                     | KMS key ARN/ID for encryption                                      | `string` | `null`  |    no    |
| recovery_window_in_days        | Days to retain after deletion (0 or 7-30)                          | `number` | `null`  |    no    |
| force_overwrite_replica_secret | Overwrite same-named secret in destination region                  | `bool`   | `false` |    no    |

### Secret Value Storage

| Name                  | Description                                   | Type           | Default | Required |
| --------------------- | --------------------------------------------- | -------------- | ------- | :------: |
| secret_string         | Plaintext or JSON secret data (sensitive)     | `string`       | `null`  |    no    |
| secret_binary         | Base64-encoded binary data (sensitive)        | `string`       | `null`  |    no    |
| version_stages        | Staging labels for the secret version         | `list(string)` | `null`  |    no    |
| ignore_secret_changes | Ignore external changes (for rotated secrets) | `bool`         | `false` |    no    |

### Multi-Region Replication

| Name    | Description                   | Type          | Default | Required |
| ------- | ----------------------------- | ------------- | ------- | :------: |
| replica | Map of replica configurations | `map(object)` | `null`  |    no    |

### Random Password Generation

| Name                             | Description               | Type     | Default                   | Required |
| -------------------------------- | ------------------------- | -------- | ------------------------- | :------: |
| create_random_password           | Generate random password  | `bool`   | `false`                   |    no    |
| random_password_length           | Password length (8-256)   | `number` | `32`                      |    no    |
| random_password_override_special | Custom special characters | `string` | `"!@#$%&*()-_=+[]{}<>:?"` |    no    |

### Resource Policy

| Name                      | Description                           | Type           | Default | Required |
| ------------------------- | ------------------------------------- | -------------- | ------- | :------: |
| create_policy             | Create resource-based IAM policy      | `bool`         | `false` |    no    |
| source_policy_documents   | List of IAM policy documents to merge | `list(string)` | `[]`    |    no    |
| override_policy_documents | Override policies by SID              | `list(string)` | `[]`    |    no    |
| policy_statements         | Custom IAM policy statements          | `map(object)`  | `null`  |    no    |
| block_public_policy       | Block public access policies          | `bool`         | `true`  |    no    |

### Secret Rotation

| Name                | Description                                    | Type     | Default | Required |
| ------------------- | ---------------------------------------------- | -------- | ------- | :------: |
| enable_rotation     | Enable automatic rotation                      | `bool`   | `false` |    no    |
| rotation_lambda_arn | Lambda ARN for rotation                        | `string` | `null`  |    no    |
| rotate_immediately  | Rotate on creation (true) or wait for schedule | `bool`   | `null`  |    no    |
| rotation_rules      | Rotation schedule configuration                | `object` | `null`  |    no    |

## Outputs

| Name                       | Description                    | Sensitive |
| -------------------------- | ------------------------------ | --------- |
| secret_arn                 | The ARN of the secret          | no        |
| secret_id                  | The ID of the secret           | no        |
| secret_name                | The name of the secret         | no        |
| secret_replica             | Attributes of replicas created | no        |
| secret_version_id          | The version ID of the secret   | no        |
| secret_string              | The decrypted secret string    | yes       |
| secret_binary              | The decrypted binary data      | yes       |
| secret_rotation_enabled    | Whether rotation is enabled    | no        |
| secret_rotation_lambda_arn | Lambda ARN handling rotation   | no        |
| secret_policy              | The resource-based IAM policy  | no        |
| random_password            | The generated random password  | yes       |

## Region Prefix Mapping

The module automatically derives region prefixes for consistent naming:

| Region         | Prefix | Region       | Prefix |
| -------------- | ------ | ------------ | ------ |
| us-east-1      | ause1  | eu-west-1    | euw1   |
| us-east-2      | ause2  | eu-west-2    | euw2   |
| us-west-1      | usw1   | eu-west-3    | euw3   |
| us-west-2      | usw2   | eu-central-1 | euc1   |
| ap-southeast-1 | apse1  | eu-north-1   | eun1   |
| ap-northeast-1 | apne1  | ca-central-1 | cac1   |

_And 20+ more regions supported_

## Secret Naming Convention

By default, secrets are named:

```
{region_prefix}-secret-{account_name}-{project_name}
```

Example: `ause1-secret-prod-myapp`

You can override this by providing `name` or `name_prefix`.

## Rotation Configuration

### Frequency-Based

```hcl
rotation_rules = {
  automatically_after_days = 30  # Rotate every 30 days
  duration                 = "3h"  # 3-hour rotation window
}
```

### Cron-Based

```hcl
rotation_rules = {
  schedule_expression = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC
  duration            = "3h"
}
```

### Rate-Based

```hcl
rotation_rules = {
  schedule_expression = "rate(30 days)"  # Every 30 days
  duration            = "3h"
}
```

## Best Practices

### Security

1. **Use KMS encryption** for sensitive secrets
2. **Enable rotation** for database credentials
3. **Use IAM policies** to restrict access
4. **Block public policies** to prevent accidental exposure
5. **Set recovery windows** (30 days recommended for production)

### Rotation

1. **Use `ignore_secret_changes = true`** for rotated secrets
2. **Test rotation logic** in non-production first
3. **Monitor rotation** via CloudWatch Logs
4. **Ensure Lambda permissions** are correctly configured

### Multi-Region

1. **Use separate KMS keys** per region for compliance
2. **Test failover** scenarios regularly
3. **Monitor replication** status
4. **Consider costs** (replication incurs cross-region data transfer)

### Cost Optimization

1. **Use appropriate recovery windows** (0 days for dev/test)
2. **Minimize replication** to only necessary regions
3. **Use random password generation** instead of storing passwords in state
4. **Clean up unused secrets** regularly

## License

MIT License - see [LICENSE](./LICENSE) for details.

## Author

Created and maintained by [Jhon Meza](https://github.com/jhonmezaa).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
