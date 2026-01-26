terraform {
  required_version = ">= 1.0"

  backend "local" {
    path = "./terraform.tfstate"
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

module "compute" {
  source = "./modules/compute"

  environment        = var.environment
  project_name       = var.project_name
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  key_name           = var.key_name
  subnet_id          = module.vpc.public_subnet_ids[0]
  vpc_id             = module.vpc.vpc_id
  security_group_ids = []
}

module "rds" {
  source = "./modules/rds"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ec2_security_group_ids = [module.compute.security_group_id]
  db_password            = var.db_password
}