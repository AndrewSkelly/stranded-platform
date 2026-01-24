variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "security_group_ids" {
  description = "List of existing security group IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = ""
}

# Outputs
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.main[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.main.id
}
