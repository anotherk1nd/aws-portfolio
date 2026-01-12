# Quick Start Guide - No Custom Domain

This simplified setup skips custom domain configuration and uses CloudFront's default HTTPS domain.

## What You'll Get

- Secure HTTPS website at `https://d1234abcd.cloudfront.net`
- All the same security features (TLS 1.2+, security headers, private S3)
- Can add custom domain later without rebuilding

## Installation (macOS without Homebrew)

### 1. Install AWS CLI

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
aws --version
```

### 2. Install Terraform

```bash
# Download (check https://www.terraform.io/downloads for latest version)
curl -O https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_darwin_amd64.zip

# Unzip and install
unzip terraform_1.7.0_darwin_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify
terraform --version
```

### 3. Configure AWS

```bash
aws configure
```

Enter:
- AWS Access Key ID (from AWS Console → IAM)
- AWS Secret Access Key
- Default region: `eu-central-1`
- Output format: `json`

## Deployment Steps

### 1. Prepare Configuration

Rename the Terraform files:
```bash
mv main-no-domain.tf main.tf
cp terraform-no-domain.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
bucket_name = "josh-portfolio-2025"  # Change to something unique
```

### 2. Customize Your Website

Edit `index.html` with your actual:
- CERN experience details
- Contact information
- Skills
- Any additional sections

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Create the infrastructure (takes ~5-10 minutes)
terraform apply
```

Type `yes` when prompted.

### 4. Upload Your Website

After `terraform apply` completes, it will show your bucket name:

```bash
# Upload index.html
aws s3 cp index.html s3://YOUR-BUCKET-NAME/

# Verify upload
aws s3 ls s3://YOUR-BUCKET-NAME/
```

### 5. Get Your Website URL

```bash
terraform output website_url
```

This will show something like: `https://d1234abcd.cloudfront.net`

Visit that URL - your site is live!

## Making Updates

### Update Website Content

```bash
# Edit index.html
# Then upload:
aws s3 cp index.html s3://YOUR-BUCKET-NAME/

# Clear CloudFront cache to see changes immediately
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

Changes will be visible in 1-2 minutes.

## Security Features

✅ **HTTPS Only** - CloudFront provides free SSL certificate
✅ **Private S3 Bucket** - No public access
✅ **Security Headers** - HSTS, CSP, X-Frame-Options, etc.
✅ **TLS 1.2+** - Modern encryption
✅ **EU Data Residency** - S3 bucket in Frankfurt
✅ **Encryption at Rest** - AES256 on S3
✅ **Versioning** - Can rollback changes

## Cost

- **S3**: ~$0.02/month (minimal storage)
- **CloudFront**: $1-2/month (includes 50GB/month free tier first year)
- **Total**: ~$1-3/month

## Adding Custom Domain Later

When you're ready to add a custom domain:
1. Update `main.tf` to add ACM certificate and domain configuration
2. Run `terraform apply`
3. Add DNS records

No need to rebuild everything from scratch.

## Troubleshooting

### "Bucket already exists"
Bucket names must be globally unique. Change `bucket_name` in terraform.tfvars

### "Access Denied" when uploading
Check your AWS credentials: `aws sts get-caller-identity`

### Website shows 403 error
- Wait 5-10 minutes for CloudFront deployment to complete
- Verify file is uploaded: `aws s3 ls s3://YOUR-BUCKET-NAME/`

### Changes not showing
Create invalidation to clear cache (see "Making Updates" above)

## Next Steps

### Add More Content
- Create additional HTML pages (about.html, projects.html)
- Upload images or documents
- Add a blog section

### Security Enhancements
- Add WAF rules
- Enable CloudFront access logging
- Set up monitoring with CloudWatch

### CI/CD
Set up automatic deployment with GitHub Actions when you push changes.

## Cleanup

To delete everything:

```bash
# Delete S3 bucket contents first
aws s3 rm s3://YOUR-BUCKET-NAME/ --recursive

# Then destroy infrastructure
terraform destroy
```

Type `yes` to confirm.

---

**Your website showcases:**
- Infrastructure as Code (Terraform)
- AWS security best practices
- Cloud architecture knowledge
- EU data residency compliance

Perfect for a security engineer portfolio!
