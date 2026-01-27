#!/bin/bash
# User data script for ECS EC2 instances

# Update the instance
yum update -y

# Install ECS agent
yum install -y ecs-init

# Configure ECS agent
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config

# Start the ECS agent
systemctl enable ecs
systemctl start ecs

# Install Docker
yum install -y docker
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user
