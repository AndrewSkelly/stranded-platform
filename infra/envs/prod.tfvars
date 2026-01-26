# Production environment variables
aws_region            = "eu-west-1"
environment           = "prod"
project_name          = "stranded-platform"
instance_type         = "t3.micro"
ami_id                = "ami-0fb0c2e454e295726" # Amazon Linux 2 eu-west-1
key_name              = ""
db_password           = "changeme123!"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones     = ["eu-west-1a", "eu-west-1b"]
