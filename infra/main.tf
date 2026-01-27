terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket       = "stranded-platform-terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  subnet_ids         = module.vpc.private_subnet_ids
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  db_host            = module.rds.db_instance_endpoint
  db_port            = module.rds.db_instance_port
  db_password        = var.db_password
}

module "rds" {
  source = "./modules/rds"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ec2_security_group_ids = [module.ecs.ecs_security_group_id]
  db_password            = var.db_password
}