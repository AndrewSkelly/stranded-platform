# Stranded Platform Infrastructure

Terraform infrastructure for deploying Stranded Platform on AWS with complete VPC networking, compute, and database resources.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                │
├─────────────────────────────────────────────────────────────┤
│  Public Subnets (10.0.1.0/24, 10.0.2.0/24)                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  EC2 Instance (t3.micro)                          │    │
│  │  - NestJS API Host                                │    │
│  │  - Public IP, SSH Access                           │    │
│  │  - Security Group: SSH (22), HTTP (80)            │    │
│  └─────────────────────────────────────────────────────┘    │
│           │                                                   │
│           │ Internet Gateway                                   │
│           ▼                                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Internet                                          │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│  Private Subnets (10.0.10.0/24, 10.0.20.0/24)              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  RDS PostgreSQL (db.t3.micro)                       │    │
│  │  - Database: stranded_platform                      │    │
│  │  - Port: 5432                                      │    │
│  │  - Security Group: PostgreSQL from EC2 SG          │    │
│  └─────────────────────────────────────────────────────┘    │
│           │                                                   │
│           │ NAT Gateway                                       │
│           ▼                                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Internet (via NAT)                               │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Infrastructure Components

### VPC & Networking
- **VPC**: 10.0.0.0/16 with DNS support enabled
- **Public Subnets**: 2 subnets across availability zones (eu-west-1a, eu-west-1b)
- **Private Subnets**: 2 subnets across availability zones for RDS
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access
- **Route Tables**: Separate routing for public and private subnets

### Compute
- **EC2 Instance**: 1x t3.micro Amazon Linux 2
- **Placement**: Public subnet for internet accessibility
- **Security**: SSH (22) and HTTP (80) access from anywhere
- **Key Pair**: Configurable SSH key for instance access

### Database
- **RDS PostgreSQL**: db.t3.micro instance
- **Version**: PostgreSQL 15.4
- **Storage**: 20GB GP2 storage, auto-scaling to 100GB
- **Placement**: Private subnets for security
- **Security**: Accessible only from EC2 security group
- **Backup**: 7-day retention period
- **Encryption**: Storage encryption enabled

## Environment Configuration

### Development (dev.tfvars)
- Region: eu-west-1
- Instance: t3.micro
- Database: PostgreSQL with development settings
- Key Pair: dev-keypair

### Production (prod.tfvars)
- Region: eu-west-1
- Instance: t3.micro
- Database: PostgreSQL with production settings
- Key Pair: prod-keypair

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **SSH Key Pairs** created in AWS:
   - `dev-keypair` for development
   - `prod-keypair` for production

## Deployment

### 1. Initialize Terraform
```bash
cd infra
terraform init
```

### 2. Plan Deployment
```bash
# Development
terraform plan -var-file="envs/dev.tfvars"

# Production
terraform plan -var-file="envs/prod.tfvars"
```

### 3. Apply Infrastructure
```bash
# Development
terraform apply -var-file="envs/dev.tfvars"

# Production
terraform apply -var-file="envs/prod.tfvars"
```

## Outputs

After deployment, you'll get the following outputs:

### Compute
- `instance_ids`: EC2 instance IDs
- `instance_public_ips`: Public IP addresses
- `instance_private_ips`: Private IP addresses
- `security_group_id`: EC2 security group ID

### Networking
- `vpc_id`: VPC ID
- `public_subnet_ids`: Public subnet IDs
- `private_subnet_ids`: Private subnet IDs

### Database
- `db_instance_endpoint`: RDS connection endpoint
- `db_instance_port`: Database port (5432)
- `rds_security_group_id`: RDS security group ID

## Application Configuration

### NestJS API Database Connection
Use the following environment variables for your NestJS application:

```bash
DB_HOST=<db_instance_endpoint_output>
DB_PORT=5432
DB_NAME=stranded_platform
DB_USERNAME=postgres
DB_PASSWORD=<your_db_password>
```

### SSH Access to EC2
```bash
ssh -i /path/to/your-keypair.pem ec2-user@<instance_public_ip>
```

## Security Considerations

- **Database**: Placed in private subnets, only accessible from EC2
- **SSH**: Key-based authentication only
- **Network**: Security groups restrict traffic to necessary ports
- **Encryption**: RDS storage encryption enabled
- **State**: Terraform state stored in encrypted S3 bucket

## Cost Estimation

### Monthly Costs (eu-west-1)
- **EC2 t3.micro**: ~$8.50/month
- **RDS db.t3.micro**: ~$13.50/month
- **NAT Gateway**: ~$32.00/month (data transfer dependent)
- **Data Transfer**: Variable based on usage

**Estimated Total**: ~$54.00/month + data transfer

## Maintenance

### Updates
- Apply OS updates to EC2 instance regularly
- Monitor RDS maintenance windows
- Update Terraform modules as needed

### Backups
- RDS automatic backups enabled (7-day retention)
- Consider manual snapshots before major changes
- Terraform state backed up in S3

### Monitoring
- Set up CloudWatch alarms for EC2 and RDS metrics
- Monitor database connections and performance
- Track data transfer costs

## Troubleshooting

### Common Issues

1. **Cannot connect to RDS from EC2**
   - Verify security group rules
   - Check subnet associations
   - Ensure RDS is in available state

2. **EC2 cannot access internet**
   - Verify public subnet association
   - Check route table configuration
   - Ensure internet gateway is attached

3. **SSH connection fails**
   - Verify key pair name and permissions
   - Check security group allows port 22
   - Ensure instance is in running state

### Commands for Debugging
```bash
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# Import existing resources if needed
terraform import aws_vpc.main vpc-id
```

## File Structure

```
infra/
├── main.tf              # Main configuration
├── variables.tf          # Input variables
├── outputs.tf           # Output definitions
├── versions.tf          # Provider versions
├── README.md           # This file
├── envs/
│   ├── dev.tfvars      # Development variables
│   └── prod.tfvars     # Production variables
└── modules/
    ├── compute/         # EC2 instance module
    │   ├── main.tf
    │   └── variables.tf
    ├── vpc/            # VPC networking module
    │   ├── main.tf
    │   └── variables.tf
    └── rds/            # RDS PostgreSQL module
        ├── main.tf
        └── variables.tf
```

## Contributing

1. Make changes to appropriate module files
2. Test with `terraform plan` before applying
3. Update documentation for any architectural changes
4. Use consistent naming conventions across environments
