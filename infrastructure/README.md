# Infrastructure as Code

This repository contains Terraform configurations for managing AWS infrastructure.

## Directory Structure

````
.
├── README.md
├── docker
│   └── compose.yml
└── terraform
    ├── envs
    │   ├── dev
    │   │   ├── backend.tf    # Dev environment state configuration
    │   │   ├── main.tf       # Dev environment resource configuration
    │   │   ├── terraform.tfvars  # Dev environment variables
    │   │   └── variables.tf   # Dev environment variable definitions
    │   ├── prd
    │   │   └── backend.tf    # Production environment state configuration
    │   └── stg
    │       └── backend.tf    # Staging environment state configuration
    ├── modules
    │   └── network           # Network module
    │       ├── main.tf       # Main network configuration
    │       ├── outputs.tf    # Network outputs
    │       └── variables.tf  # Network variable definitions
    └── shared
        ├── provider.tf       # AWS provider configuration
        └── variables.tf      # Shared variable definitions

## Prerequisites
- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- S3 bucket for Terraform state
- DynamoDB table for state locking

## Usage

1. Initialize Terraform:
```bash
cd terraform/envs/dev
terraform init
````

2. Plan the changes:

```bash
terraform plan
```

3. Apply the changes:

```bash
terraform apply
```

## State Management

- State files are stored in S3
- State locking is managed through DynamoDB
- Each environment has its own state file

```bash
# S3バケットの作成（事前に必要）
aws s3 mb s3://584335737723-terraform-state

# DynamoDBテーブルの作成（State Lock用）
aws dynamodb create-table \
  --table-name 584335737723-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

cd infrastructure/terraform
terraform fmt
terraform init
terraform plan
terraform apply
terraform state mv
terraform import
terraform state pull
terraform state show
terraform state list
terraform state push
terraform state rm
terraform validate
terraform destroy


ssh -i terraform/modules/bastion/ssh/bastion ec2-user@3.112.237.225
psql -h <rds_endpoint> -U postgres -d postgres
pgAdmin4のuse sshトンネルでも接続可能
```
