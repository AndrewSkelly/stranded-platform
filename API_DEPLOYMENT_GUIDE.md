# API Deployment Guide for ECR + ECS

## What Your API Agent Needs to Do

### 1. **Build and Push Docker Image to ECR**

#### **Repository Details:**
- **Repository Name**: `stranded-platform-api`
- **Repository URL**: `671774453969.dkr.ecr.eu-west-1.amazonaws.com/stranded-platform-api`
- **Region**: `eu-west-1`

#### **Required AWS Permissions:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
```

#### **Dockerfile Requirements:**
```dockerfile
# Use Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port 3000
EXPOSE 3000

# Start the application
CMD ["node", "dist/main.js"]
```

#### **Build and Push Commands:**
```bash
# 1. Login to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 671774453969.dkr.ecr.eu-west-1.amazonaws.com

# 2. Build Docker image
docker build -t stranded-platform-api .

# 3. Tag image with version
docker tag stranded-platform-api:latest 671774453969.dkr.ecr.eu-west-1.amazonaws.com/stranded-platform-api:latest
docker tag stranded-platform-api:latest 671774453969.dkr.ecr.eu-west-1.amazonaws.com/stranded-platform-api:v1.0.0

# 4. Push to ECR
docker push 671774453969.dkr.ecr.eu-west-1.amazonaws.com/stranded-platform-api:latest
docker push 671774453969.dkr.ecr.eu-west-1.amazonaws.com/stranded-platform-api:v1.0.0
```

### 2. **Environment Variables in API**

Your API should read these environment variables:

```javascript
// Database connection
const dbConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
};

// Server configuration
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
```

### 3. **Application Requirements**

#### **Port Configuration:**
- **Listen on port 3000** (configured in ECS task definition)
- **Health check endpoint** on `/` (ALB health checks)

#### **Database Connection:**
- **Host**: Provided via `DB_HOST` environment variable
- **Port**: 5432 (PostgreSQL)
- **Database**: `stranded_platform`
- **Username**: `postgres`
- **Password**: Provided via `DB_PASSWORD` environment variable

#### **Logging:**
- **Log to stdout/stderr** (captured by CloudWatch)
- **JSON format recommended** for structured logging

### 4. **CI/CD Integration**

#### **GitHub Actions Example:**
```yaml
name: Build and Deploy API

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: eu-west-1
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: Build, tag, and push image to Amazon ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: stranded-platform-api
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
        docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
```

### 5. **Image Tagging Strategy**

#### **Recommended Tags:**
- **`latest`**: Always points to the most recent version
- **`v1.0.0`**: Semantic versioning for releases
- **`abc123def`**: Git commit SHA for traceability

#### **ECR Lifecycle Policy:**
- **Keep last 10 tagged images** with `v*` prefix
- **Delete untagged images after 1 day**
- **Automatic image scanning on push**

### 6. **Deployment Process**

#### **After Pushing Image:**
1. **ECS will automatically detect** the new image (if using `latest` tag)
2. **Update ECS service** to force new deployment:
   ```bash
   aws ecs update-service --cluster stranded-platform-prod-cluster --service stranded-platform-prod-service --force-new-deployment
   ```
3. **Monitor deployment** in ECS console
4. **Check health** via ALB URL

### 7. **Troubleshooting**

#### **Common Issues:**
- **Image pull errors**: Check ECR permissions and image tags
- **Container crashes**: Check CloudWatch logs
- **Health check failures**: Ensure app responds on port 3000
- **Database connection**: Verify environment variables

#### **Useful Commands:**
```bash
# Check ECS task logs
aws logs tail /ecs/stranded-platform-prod --follow

# Check ECS service status
aws ecs describe-services --cluster stranded-platform-prod-cluster --services stranded-platform-prod-service

# Check running tasks
aws ecs list-tasks --cluster stranded-platform-prod-cluster
```

## Summary

Your API agent needs to:
1. **Build Docker image** with proper Dockerfile
2. **Push to ECR** with appropriate tags
3. **Handle environment variables** for database connection
4. **Listen on port 3000** with health check endpoint
5. **Log to stdout** for CloudWatch integration

The infrastructure is already configured to pull from ECR and run your API with all necessary environment variables!
