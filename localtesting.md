# Local Infrastructure Testing Guide

This guide walks through testing the Terraform infrastructure locally, verifying resources in AWS console, and cleaning up.

## Prerequisites

1. **AWS CLI** configured with credentials:
   ```bash
   aws configure
   ```

2. **Terraform** installed (>= 1.0):
   ```bash
   terraform --version
   ```

3. **SSH Key Pair** created in AWS console:
   - Name: `dev-keypair`
   - Download the .pem file

## Testing Steps

### 1. Initialize Terraform
```bash
cd infra
terraform init
```

### 2. Plan the Deployment
Review what will be created:
```bash
terraform plan -var-file="envs/dev.tfvars"
```

### 3. Apply Infrastructure
Create all AWS resources:
```bash
terraform apply -var-file="envs/dev.tfvars"
```
- Type `yes` when prompted
- Takes ~10-15 minutes to complete

### 4. Verify Resources in AWS Console

#### VPC Dashboard
Navigate to **VPC → Your VPCs** and verify:
- **VPC**: `stranded-platform-dev-vpc` (10.0.0.0/16)
- **Subnets**: 
  - `stranded-platform-dev-public-1` (10.0.1.0/24)
  - `stranded-platform-dev-public-2` (10.0.2.0/24)
  - `stranded-platform-dev-private-1` (10.0.10.0/24)
  - `stranded-platform-dev-private-2` (10.0.20.0/24)
- **Internet Gateway**: `stranded-platform-dev-igw`
- **NAT Gateway**: `stranded-platform-dev-nat`
- **Route Tables**: `stranded-platform-dev-public-rt`, `stranded-platform-dev-private-rt`

#### EC2 Dashboard
Navigate to **EC2 → Instances** and verify:
- **Instance**: `stranded-platform-dev-1` (t3.micro)
- **State**: Running
- **Public IP**: Assigned
- **Security Group**: `stranded-platform-dev-sg-dev-sg`

#### RDS Dashboard
Navigate to **RDS → Databases** and verify:
- **Database**: `stranded-platform-dev-db`
- **Engine**: PostgreSQL 15.4
- **Instance Class**: db.t3.micro
- **Status**: Available
- **VPC Security Group**: `stranded-platform-dev-rds-sg`

### 5. Get Connection Details
```bash
terraform output
```

Expected outputs:
- `instance_public_ips`: EC2 public IP
- `db_instance_endpoint`: RDS endpoint
- `db_instance_port`: 5432

### 6. Test Connectivity (Optional)

#### SSH into EC2
```bash
ssh -i /path/to/dev-keypair.pem ec2-user@<EC2_PUBLIC_IP>
```

#### Test Database Connection from EC2
```bash
# Install PostgreSQL client
sudo yum install postgresql -y

# Connect to database
psql -h <RDS_ENDPOINT> -U postgres -d stranded_platform -p 5432
# Password: changeme123!
```

#### Test Internet Access
```bash
# From EC2 instance
curl -I https://www.google.com
ping 8.8.8.8
```

### 7. Clean Up Resources
```bash
terraform destroy -var-file="envs/dev.tfvars"
```
- Type `yes` when prompted
- Takes ~5-10 minutes to complete
- Verify all resources are deleted in AWS console

## Troubleshooting

### Common Issues

#### Terraform Init Fails
```bash
# Check AWS credentials
aws sts get-caller-identity
```

#### Apply Fails with Permissions
Ensure your IAM user has these permissions:
- AmazonVPCFullAccess
- AmazonEC2FullAccess
- AmazonRDSFullAccess
- IAMFullAccess (for creating roles)

#### RDS Creation Fails
- Check if the subnet group has at least 2 subnets in different AZs
- Verify security group allows PostgreSQL traffic
- Check if db.t3.micro is available in eu-west-1

#### NAT Gateway Stuck in Pending
- NAT Gateway creation can take 5-10 minutes
- Check if Elastic IP is available
- Verify internet gateway is attached to VPC

#### Cannot SSH to EC2
```bash
# Check security group allows SSH (port 22)
# Verify key pair name matches
# Check instance is in running state
# Ensure you're using correct .pem file
```

### Debug Commands

#### Check Terraform State
```bash
terraform show
terraform state list
terraform state show aws_vpc.main
```

#### Validate Configuration
```bash
terraform validate
terraform fmt -check
```

#### Force Unlock (if state is locked)
```bash
terraform force-unlock LOCK_ID
```

## Resource Cleanup Verification

After running `terraform destroy`, verify these are deleted:

### VPC Resources
- VPC itself
- All subnets
- Route tables
- Internet gateway
- NAT gateway
- Elastic IPs

### Compute Resources
- EC2 instance
- Security groups
- Key pairs (remain - delete manually if needed)

### Database Resources
- RDS instance
- DB subnet groups
- RDS security groups
- Final snapshots (if not skipped)

## Cost Monitoring

During testing, monitor costs in:
- **AWS Cost Explorer**: Track spending by service
- **Billing Dashboard**: Real-time cost alerts
- **CloudWatch**: Resource usage metrics

Estimated testing cost: ~$2-5 for 2-3 hours of usage.

## Next Steps

After successful testing:
1. Update `.tfvars` files with production values
2. Create production key pair
3. Set up proper IAM roles for production
4. Configure monitoring and alerts
5. Set up automated backups

## Safety Tips

1. **Always use development environment first**
2. **Check costs before leaving resources running**
3. **Use `terraform plan` before every apply**
4. **Keep .tfstate files secure and backed up**
5. **Never commit secrets to version control**
6. **Use IAM roles instead of root credentials**
