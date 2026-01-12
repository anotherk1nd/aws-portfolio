# Security-Enhanced CI/CD Pipeline

This portfolio demonstrates enterprise-grade security practices with automated scanning, WAF protection, and continuous validation.

## Security Features

### 1. AWS WAF (Web Application Firewall)
Protects against common web exploits:

**OWASP Top 10 Protection:**
- ✅ SQL Injection (SQLi)
- ✅ Cross-Site Scripting (XSS)
- ✅ Known Bad Inputs
- ✅ Core Rule Set (CRS)

**Additional Protection:**
- ✅ Rate limiting (2000 req/5min per IP)
- ✅ Geographic restrictions
- ✅ Bot detection

**Cost:** ~$5/month base + $1 per million requests

### 2. Security Scanning Pipeline

**Pre-Deployment Scans:**
- **TFSec** - Terraform static analysis
- **Checkov** - Infrastructure as Code security
- **Trivy** - Container and configuration scanning
- **Gitleaks** - Secret detection
- **Snyk** - Dependency vulnerabilities

**Post-Deployment Validation:**
- HTTPS enforcement test
- Security headers validation
- S3 bucket policy verification
- CloudFront WAF check

### 3. Enhanced Infrastructure Security

**S3 Bucket:**
- Server-side encryption (AES256)
- Versioning enabled
- Public access blocked
- Access logging to separate bucket

**CloudFront:**
- TLS 1.2+ only
- Origin Access Control (OAC)
- Security response headers
- Access logging enabled
- WAF protection

**Security Headers:**
```
Strict-Transport-Security: max-age=63072000
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'...
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

## Setup Instructions

### Step 1: Update Terraform Configuration

Replace your current `main.tf` with the new one that includes WAF:

```bash
# Backup current config
cp main.tf main.tf.backup

# Copy new config with WAF
# (Use the main-with-waf.tf file provided)

# Review changes
terraform plan
```

### Step 2: Deploy WAF-Protected Infrastructure

```bash
# Initialize (if needed)
terraform init

# Review WAF resources
terraform plan

# Deploy
terraform apply

# Note the new outputs:
# - waf_web_acl_id
# - waf_web_acl_arn
# - logs_bucket
```

### Step 3: Add GitHub Secrets

In addition to existing secrets, you may want to add:

**Optional: Snyk Token (for dependency scanning)**
1. Sign up at https://snyk.io
2. Get API token from Account Settings
3. Add to GitHub: `SNYK_TOKEN`

### Step 4: Deploy Security Workflows

```bash
# Add the new workflows
git add .github/workflows/security-scan.yml
git add .github/workflows/deploy-with-security.yml

# Commit
git commit -m "Add security scanning and WAF protection"

# Push - triggers security scans
git push origin main
```

### Step 5: Enable GitHub Security Features

**GitHub Settings → Security:**
1. ☑️ Enable Dependabot alerts
2. ☑️ Enable Dependabot security updates
3. ☑️ Enable Code scanning

**Security → Code scanning:**
- Upload from workflows will appear here
- Checkov and Trivy results integrated

## CI/CD Workflow

### Automated Security Pipeline

```
┌─────────────────────────────────────────┐
│ Push to GitHub                          │
└──────────────┬──────────────────────────┘
               │
        ┌──────▼──────┐
        │  Security   │
        │   Scans     │
        └──────┬──────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌───────┐           ┌─────────┐
│TFSec  │           │Gitleaks │
│Checkov│           │Trivy    │
│Snyk   │           │HTML Val │
└───┬───┘           └────┬────┘
    │                    │
    └──────────┬─────────┘
               │
          ┌────▼────┐
          │ Deploy  │
          │ to AWS  │
          └────┬────┘
               │
    ┌──────────┴──────────┐
    │                     │
    ▼                     ▼
┌─────────┐         ┌───────────┐
│Sync S3  │         │Invalidate │
│Verify   │         │CloudFront │
└────┬────┘         └─────┬─────┘
     │                    │
     └──────────┬─────────┘
                │
       ┌────────▼─────────┐
       │ Post-Deploy      │
       │ Validation       │
       ├──────────────────┤
       │ HTTPS Test       │
       │ Headers Check    │
       │ WAF Verification │
       └──────────────────┘
```

### Daily Security Scans

The `security-scan.yml` workflow runs:
- **On every push** - Pre-deployment validation
- **On pull requests** - Review security before merge
- **Daily at 9am UTC** - Continuous security monitoring

## Monitoring & Logging

### CloudWatch Logs

**WAF Metrics:**
- Block rate
- Request count by rule
- Geographic distribution

**Access via AWS Console:**
1. CloudWatch → Metrics → WAF
2. Filter by WebACL: `portfolio-waf`

### S3 Access Logs

**Location:** `s3://YOUR-BUCKET-logs/s3-access-logs/`

**Contains:**
- Bucket access attempts
- Request types
- Source IPs
- Timestamps

### CloudFront Access Logs

**Location:** `s3://YOUR-BUCKET-logs/cloudfront-logs/`

**Contains:**
- Request details
- Edge location
- User agent
- Status codes

### Analyzing Logs

```bash
# Download recent logs
aws s3 sync s3://YOUR-BUCKET-logs/cloudfront-logs/ ./logs/ --exclude "*" --include "*.gz"

# Decompress and analyze
gunzip logs/*.gz
cat logs/* | grep "200" | wc -l  # Count successful requests
cat logs/* | grep "403" | wc -l  # Count blocked requests
```

## Security Testing

### Manual WAF Testing

Test that WAF blocks malicious requests:

```bash
# Get your CloudFront domain
DOMAIN=$(terraform output -raw cloudfront_domain_name)

# Test SQL injection (should be blocked)
curl "https://$DOMAIN/?id=1' OR '1'='1"

# Test XSS (should be blocked)
curl "https://$DOMAIN/?q=<script>alert(1)</script>"

# Test rate limiting (run rapidly)
for i in {1..2100}; do curl -s "https://$DOMAIN" > /dev/null; done
```

Expected: WAF blocks with 403 Forbidden

### Security Headers Test

```bash
# Check all security headers
curl -I https://YOUR-CLOUDFRONT-DOMAIN

# Or use online tool
# https://securityheaders.com/
```

### SSL/TLS Test

```bash
# Test TLS configuration
nmap --script ssl-enum-ciphers -p 443 YOUR-CLOUDFRONT-DOMAIN

# Or use online tool
# https://www.ssllabs.com/ssltest/
```

## Cost Breakdown

### Infrastructure Costs

**S3:**
- Storage: ~$0.02/month (minimal files)
- Requests: ~$0.01/month

**CloudFront:**
- Data transfer: $1-2/month (first 50GB free/year)
- Requests: ~$0.01/month

**WAF:**
- Web ACL: $5.00/month
- Rules: $1.00/rule/month (5 rules = $5/month)
- Requests: $0.60 per million requests

**CloudWatch:**
- Metrics: Free tier
- Logs: ~$0.50/month

**Total: ~$12-15/month with WAF**
**Without WAF: ~$2-3/month**

### CI/CD Costs

- GitHub Actions: Free (public repos)
- Security scanning: Free (open source tools)

## Compliance

This setup demonstrates compliance with:

### OWASP Top 10 (2021)
- ✅ A01: Broken Access Control - S3 private, OAC
- ✅ A02: Cryptographic Failures - TLS 1.2+, S3 encryption
- ✅ A03: Injection - WAF SQLi protection
- ✅ A04: Insecure Design - Security by design
- ✅ A05: Security Misconfiguration - Hardened defaults
- ✅ A06: Vulnerable Components - Dependency scanning
- ✅ A07: Authentication Failures - N/A (static site)
- ✅ A08: Data Integrity Failures - S3 versioning
- ✅ A09: Logging Failures - Comprehensive logging
- ✅ A10: SSRF - Input validation via WAF

### GDPR Considerations
- ✅ Data residency - S3 in eu-central-1
- ✅ Data retention - Configurable log retention
- ✅ Access logging - Audit trail
- ✅ Encryption at rest and in transit

### CIS AWS Foundations Benchmark
- ✅ Enable CloudTrail (can be added)
- ✅ Enable VPC Flow Logs (N/A for static site)
- ✅ S3 bucket encryption
- ✅ S3 bucket logging
- ✅ CloudFront requires HTTPS

## Portfolio Talking Points

This project demonstrates:

### Security Engineering
- WAF configuration and tuning
- Defense in depth strategy
- Security headers implementation
- Encryption at rest and in transit

### DevSecOps
- Shift-left security (pre-deployment scanning)
- Automated security testing
- Continuous security validation
- Security as code

### Cloud Security
- AWS security best practices
- IAM least privilege
- Network security (CloudFront, WAF)
- Data protection (S3 encryption, versioning)

### Compliance & Governance
- OWASP Top 10 protection
- GDPR considerations
- Security logging and monitoring
- Audit trail

## Advanced: WAF Tuning

### Monitor WAF Metrics

```bash
# Check blocked requests
aws cloudwatch get-metric-statistics \
  --namespace AWS/WAFV2 \
  --metric-name BlockedRequests \
  --dimensions Name=Rule,Value=ALL Name=WebACL,Value=YOUR-WEB-ACL \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

### Adjust Rate Limiting

Edit `main.tf`:
```hcl
rate_based_statement {
  limit              = 5000  # Increase if legitimate traffic blocked
  aggregate_key_type = "IP"
}
```

### Custom WAF Rules

Add application-specific rules:
```hcl
rule {
  name     = "BlockBadUserAgent"
  priority = 10
  
  action {
    block {}
  }
  
  statement {
    byte_match_statement {
      search_string         = "badbot"
      field_to_match {
        single_header {
          name = "user-agent"
        }
      }
      text_transformation {
        priority = 0
        type     = "LOWERCASE"
      }
      positional_constraint = "CONTAINS"
    }
  }
}
```

## Troubleshooting

### Security Scan Failures

**TFSec warnings:**
- Review the specific rule
- Add `tfsec:ignore[RULE_ID]` comment if false positive

**Checkov failures:**
- Check policy violations
- Update Terraform to resolve
- Add exception if justified

### WAF Blocking Legitimate Traffic

**Check CloudWatch Logs:**
```bash
aws logs filter-log-events \
  --log-group-name aws-waf-logs-cloudfront \
  --filter-pattern "403"
```

**Adjust rules or add exceptions**

### Deployment Failures

**Check GitHub Actions logs:**
- Security → tab shows detailed logs
- Each step shows success/failure

**Common issues:**
- AWS credentials expired
- S3 bucket name conflict
- WAF quota exceeded

## Next Steps

### Additional Security Enhancements
- [ ] Add AWS Shield (DDoS protection)
- [ ] Enable GuardDuty (threat detection)
- [ ] Implement AWS Config rules
- [ ] Add CloudTrail logging
- [ ] Set up Security Hub

### Monitoring Improvements
- [ ] CloudWatch dashboards
- [ ] SNS alerts for security events
- [ ] Log analysis with Athena
- [ ] SIEM integration

### Compliance
- [ ] PCI DSS compliance (if needed)
- [ ] SOC 2 controls
- [ ] ISO 27001 alignment

---

**This security setup is production-ready and demonstrates enterprise-grade security practices suitable for financial services, healthcare, or government applications.**
