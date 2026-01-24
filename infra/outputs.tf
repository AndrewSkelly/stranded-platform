output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = module.compute.instance_public_ips
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = module.compute.instance_private_ips
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.compute.security_group_id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.rds.security_group_id
}
