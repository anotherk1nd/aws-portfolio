# Secure AWS Portfolio Website Setup Guide

This guide will help you deploy a simple, secure static website on AWS using S3, CloudFront, and ACM.

## Architecture Overview

- **S3 Bucket** (eu-central-1): Stores website files, private access only
- **CloudFront**: Global CDN with HTTPS, serves from EU edge locations
- **ACM Certificate** (us-east-1): Free SSL/TLS certificate
- **Security Features**: HSTS, CSP, X-Frame-Options, TLS 1.2+, private S3 bucket

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Domain name** (can use Route 53 or any registrar)
3. **AWS CLI** installed and configured
4. **Terraform** installed (version >= 1.0)

## Step-by-Step Setup

### 1. Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-central-1
# Default output format: json
```

### 2. Prepare Your Configuration

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your details:
```hcl
domain_name = "yourdomain.com"
bucket_name = "your-unique-bucket-name-2025"
```

### 3. Customize Your Website

Edit `index.html` to add your:
- Name and title
- Bio/summary
- Work experience (especially CERN details)
- Technical skills
- Contact information (email, LinkedIn, GitHub)

### 4. Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider and sets up Terraform.

### 5. Review the Infrastructure Plan

```bash
terraform plan
```

Review the resources that will be created:
- S3 bucket with versioning and encryption
- CloudFront distribution with security headers
- ACM certificate
- Origin Access Control
- Bucket policy

### 6. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This will:
- Create S3 bucket in Frankfurt (eu-central-1)
- Request ACM certificate in us-east-1
- Create CloudFront distribution
- Configure security policies

**Important**: The ACM certificate validation requires DNS records. Terraform will show you the DNS records to add.

### 7. Validate ACM Certificate

After running `terraform apply`, you need to add DNS records to validate your certificate:

1. Terraform will output CNAME records
2. Add these records to your domain's DNS (in Route 53 or your registrar)
3. Wait for validation (usually 5-30 minutes)

Example DNS record:
```
Type: CNAME
Name: _abc123.yourdomain.com
Value: _xyz789.acm-validations.aws
```

### 8. Upload Your Website

Once infrastructure is deployed:

```bash
aws s3 sync . s3://your-bucket-name/ \
  --exclude ".git/*" \
  --exclude "*.tf" \
  --exclude "*.tfvars*" \
  --exclude ".terraform/*" \
  --exclude "terraform.tfstate*" \
  --exclude "README.md" \
  --include "index.html"
```

Or upload just index.html:
```bash
aws s3 cp index.html s3://your-bucket-name/
```

### 9. Configure DNS

Add CNAME or A record pointing to your CloudFront distribution:

**Option A: Using CNAME (if not using root domain)**
```
Type: CNAME
Name: www
Value: d1234abcd.cloudfront.net (from terraform output)
```

**Option B: Using Route 53 Alias (recommended for root domain)**
If using Route 53, create an A record with Alias pointing to the CloudFront distribution.

### 10. Test Your Website

Wait a few minutes for DNS propagation, then visit:
- https://yourdomain.com
- https://www.yourdomain.com

Test security:
```bash
# Check security headers
curl -I https://yourdomain.com

# Verify TLS
openssl s_client -connect yourdomain.com:443 -tls1_2
```

## Security Features Implemented

✅ **No Public S3 Bucket** - CloudFront uses Origin Access Control
✅ **TLS 1.2+ Only** - Modern encryption standards
✅ **Security Headers**:
  - Strict-Transport-Security (HSTS)
  - Content-Security-Policy (CSP)
  - X-Frame-Options: DENY
  - X-Content-Type-Options: nosniff
  - X-XSS-Protection

✅ **Data Residency** - Origin in EU (Frankfurt)
✅ **Encryption at Rest** - S3 SSE-AES256
✅ **Versioning** - Rollback capability
✅ **Infrastructure as Code** - Terraform for reproducibility

## Updating Your Website

To update content:

```bash
# Edit index.html
aws s3 cp index.html s3://your-bucket-name/

# Invalidate CloudFront cache to see changes immediately
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

Get distribution ID from:
```bash
terraform output cloudfront_distribution_id
```

## Cost Estimation

- **S3 Storage**: ~$0.02/month for a simple site
- **CloudFront**: ~$1-2/month (50GB free tier first year)
- **Route 53** (if used): $0.50/month per hosted zone
- **ACM Certificate**: FREE

**Total: ~$1-3/month** (after free tier)

## Troubleshooting

### Certificate Not Validating
- Check DNS records are correct
- Wait 30 minutes for DNS propagation
- Ensure records are added to the correct domain

### 403 Forbidden Error
- Ensure S3 bucket policy is applied
- Check CloudFront distribution is deployed
- Verify index.html is uploaded

### Changes Not Showing
- Create CloudFront invalidation
- Check browser cache (Ctrl+Shift+R)
- Verify file was uploaded to S3

## Next Steps

### Add WAF (Web Application Firewall)
Protect against common attacks:
```hcl
# Add to main.tf
resource "aws_wafv2_web_acl" "website" {
  # OWASP Top 10 rules
}
```

### Add CloudFront Logging
Monitor access:
```hcl
logging_config {
  bucket = "logs-bucket.s3.amazonaws.com"
  prefix = "cloudfront/"
}
```

### Add CI/CD Pipeline
Automate deployments with GitHub Actions or GitLab CI.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

This removes:
- CloudFront distribution
- S3 bucket and contents
- ACM certificate
- All policies and configurations

## Questions?

Review AWS documentation:
- [CloudFront Security](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/SecurityAndPrivacy.html)
- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)

---

**Portfolio Talking Points:**
- "Deployed using Infrastructure as Code with Terraform"
- "Implemented security headers and TLS 1.2+ requirements"
- "EU data residency with Frankfurt S3 origin"
- "Private S3 bucket with CloudFront OAC"
- "Total infrastructure cost: ~$2/month"
