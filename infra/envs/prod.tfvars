# Production environment variables
aws_region            = "eu-west-1"
environment           = "prod"
project_name          = "stranded-platform"
instance_type         = "t3.micro"
ami_id                = "ami-0c02fb55956c7d316" # Amazon Linux 2
key_name              = "prod-keypair"
db_password           = "changeme123!"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones     = ["eu-west-1a", "eu-west-1b"]
