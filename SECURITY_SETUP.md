# Security Setup Guide

## 🔐 Required GitHub Secrets

You need to add these secrets to your GitHub repository:

### **Go to:**
1. Your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"

### **Required Secrets:**

#### 1. `AWS_ACCESS_KEY_ID`
- Your AWS access key ID
- Used for Terraform to manage AWS resources

#### 2. `AWS_SECRET_ACCESS_KEY`
- Your AWS secret access key
- Used for Terraform to manage AWS resources

#### 3. `DB_PASSWORD`
- Your PostgreSQL database password
- **Important**: Use a strong, unique password
- Example: `MyStr0ngP@ssw0rd!2024`

## 🚨 Security Best Practices

### **Password Requirements:**
- Minimum 12 characters
- Include uppercase, lowercase, numbers, and special characters
- Don't use common words or patterns

### **AWS Credentials:**
- Use IAM user with least privilege
- Rotate keys regularly
- Never commit credentials to Git

## 🛡️ What We Fixed

### **Before (Insecure):**
```hcl
db_password = "changeme123!"  # ❌ Hardcoded in Git
```

### **After (Secure):**
```hcl
db_password = "${DB_PASSWORD}"  # ✅ From environment variable
```

### **GitHub Actions:**
```yaml
-var="db_password=${{ secrets.DB_PASSWORD }}"  # ✅ Uses GitHub secret
```

## 🔄 How to Use

### **Local Development:**
```bash
# Set environment variable
export DB_PASSWORD="YourSecurePassword123!"

# Run Terraform
cd infra
terraform plan -var-file="envs/prod.tfvars" -var="db_password=$DB_PASSWORD"
```

### **CI/CD (GitHub Actions):**
1. Add `DB_PASSWORD` to GitHub secrets
2. Workflow automatically uses the secret
3. No passwords in code repository

## ✅ Security Checklist

- [ ] Added `DB_PASSWORD` to GitHub secrets
- [ ] Added AWS credentials to GitHub secrets
- [ ] Removed hardcoded passwords from code
- [ ] Using strong, unique password
- [ ] IAM user has minimum required permissions
- [ ] Secrets are not exposed in logs

## 🚀 Next Steps

1. **Add secrets** to GitHub repository
2. **Test deployment** with secure configuration
3. **Rotate passwords** regularly
4. **Monitor access** to AWS resources

Your infrastructure is now secure! 🔒
