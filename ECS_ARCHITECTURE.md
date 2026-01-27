# ECS Architecture Overview

## What We Built

### Replaced: Single EC2 Instance
- ❌ Single EC2 instance with manual deployment
- ❌ No load balancing
- ❌ No auto-scaling
- ❌ Manual container management

### With: ECS with ALB
- ✅ **ECS Cluster**: Container orchestration
- ✅ **Application Load Balancer**: Traffic distribution
- ✅ **2 ECS Tasks**: Desired count of 2 containers
- ✅ **Auto Scaling Group**: 1-4 EC2 instances for ECS
- ✅ **Health Checks**: Automatic monitoring
- ✅ **CloudWatch Logs**: Centralized logging

## Architecture Components

### 1. ECS Cluster
- **Name**: `stranded-platform-prod-cluster`
- **Launch Type**: EC2
- **Container Insights**: Enabled

### 2. ECS Service
- **Name**: `stranded-platform-prod-service`
- **Desired Count**: 2 tasks
- **Task Definition**: 256 CPU, 512 RAM
- **Container**: nginx:latest (replace with your API image)

### 3. Application Load Balancer
- **Name**: `stranded-platform-prod-alb`
- **Public**: Yes (accessible from internet)
- **Port**: 80 (HTTP)
- **Target Group**: Health checks on port 3000

### 4. Auto Scaling Group
- **Desired Capacity**: 2 EC2 instances
- **Min Size**: 1 instance
- **Max Size**: 4 instances
- **Instance Type**: t3.micro
- **Placement**: Private subnets

### 5. Security Groups
- **ALB SG**: HTTP from 0.0.0.0/0
- **ECS Tasks SG**: HTTP from ALB only
- **ECS Instances SG**: SSH + HTTP from ALB

## How It Works

```
Internet → ALB (Port 80) → ECS Tasks (Port 3000) → RDS Database
                ↓
        Health Checks & Auto Scaling
                ↓
        CloudWatch Logs & Monitoring
```

## Deployment Flow

1. **EC2 Instances** join ECS cluster
2. **ECS Service** runs 2 tasks (containers)
3. **ALB** distributes traffic to healthy tasks
4. **Health Checks** monitor task health
5. **Auto Scaling** adds/removes EC2 instances as needed

## Benefits

### High Availability
- Multiple EC2 instances across AZs
- Load balancing distributes traffic
- Health checks remove unhealthy containers

### Scalability
- Auto Scaling Group (1-4 instances)
- ECS Service can scale tasks
- ALB handles increased traffic

### Operational Excellence
- CloudWatch logging
- Health monitoring
- Automated deployments
- Container orchestration

## Next Steps

1. **Update Container Image**: Replace `nginx:latest` with your API image
2. **Environment Variables**: Configure database connection
3. **CI/CD Pipeline**: Build and push Docker images
4. **Monitoring**: Set up CloudWatch alerts
5. **SSL**: Add HTTPS certificate to ALB

## Access Points

- **Application URL**: `http://<ALB-DNS-NAME>`
- **ECS Cluster**: AWS Console → ECS
- **Load Balancer**: AWS Console → EC2 → Load Balancers
- **Logs**: CloudWatch → Log Groups → `/ecs/stranded-platform-prod`
