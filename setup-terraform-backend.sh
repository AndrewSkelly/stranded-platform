#!/bin/bash

# Setup Terraform S3 Backend with State Locking
echo "Setting up Terraform backend..."

# Create S3 bucket for state storage
aws s3api create-bucket \
  --bucket stranded-platform-terraform-state \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket stranded-platform-terraform-state \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket stranded-platform-terraform-state \
  --server-side-encryption-configuration \
  '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket stranded-platform-terraform-state \
  --public-access-block-configuration "BlockPublicAcls=true,BlockPublicPolicy=true,IgnorePublicAcls=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-1

echo "Backend setup complete!"
echo "Bucket: stranded-platform-terraform-state"
echo "DynamoDB table: terraform-state-lock"
