#!/bin/bash
# User data script for ECS EC2 instances

# Update the instance
yum update -y

# Install Docker first
yum install -y docker
systemctl enable docker
systemctl start docker

# Install ECS agent
yum install -y ecs-init

# Configure ECS agent before starting
cat << EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_DEFAULT_LAUNCH_TYPE=ec2
ECS_CONTAINER_STOP_TIMEOUT=10m
EOF

# Start the ECS agent
systemctl enable ecs
systemctl start ecs

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Log completion
echo "ECS instance setup completed at $(date)" >> /var/log/ecs-setup.log
