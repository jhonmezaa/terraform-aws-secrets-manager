# Rotated Secret Example

Secret with automatic rotation using AWS Lambda.

## Features

- Random password generation
- Automatic rotation every 30 days
- Lambda function integration
- Lifecycle ignore_changes for rotated values

## Prerequisites

- Lambda function for rotation must exist
- Lambda must have permission to access Secrets Manager

## Usage

```bash
terraform init
terraform plan
terraform apply
```
