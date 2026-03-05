# Contact Form Setup Instructions

## Overview
AWS Lambda + SES contact form that sends submissions to hello@joshuafenech.de

---

## Step 1: Verify Email in SES

```bash
# Verify your email (SES will send confirmation email)
aws ses verify-email-identity \
  --email-address hello@joshuafenech.de \
  --region eu-central-1

# Check verification status
aws ses get-identity-verification-attributes \
  --identities hello@joshuafenech.de \
  --region eu-central-1
```

**IMPORTANT:** Click the verification link in the email AWS sends to hello@joshuafenech.de

**Wait until status shows "Success" before continuing!**

---

## Step 2: Download Files

Download these 3 files to `/workspaces/aws-portfolio/`:
1. `lambda_contact_form.py` - Lambda function code
2. `contact-form-terraform.tf` - Infrastructure config
3. `CONTACT_FORM_SETUP.md` - This file

---

## Step 3: Create Lambda ZIP

```bash
cd /workspaces/aws-portfolio

# Create ZIP file for Lambda
zip lambda_contact_form.zip lambda_contact_form.py

# Verify
ls -lh lambda_contact_form.zip
```

---

## Step 4: Add Terraform Config

```bash
# Append contact form config to main Terraform file
cat contact-form-terraform.tf >> main-with-waf.tf

# Or keep separate (cleaner):
# Just leave contact-form-terraform.tf in the directory
# Terraform will pick it up automatically
```

---

## Step 5: Deploy with Terraform

```bash
# Initialize (if new resources needed)
terraform init

# Plan
terraform plan

# Should show:
# + aws_lambda_function.contact_form
# + aws_api_gateway_rest_api.contact_form
# + aws_iam_role.contact_form_lambda
# + ... (about 15 new resources)

# Apply
terraform apply
# Type 'yes' when prompted

# Save the API URL from output:
# contact_form_api_url = "https://xxxxx.execute-api.eu-central-1.amazonaws.com/prod/contact"
```

---

## Step 6: Update Contact Form HTML

Edit `_layouts/default.html`, find the contact form (around line 90):

**Change from:**
```html
<form method="post" action="#">
```

**To:**
```html
<form method="post" action="https://YOUR-API-ID.execute-api.eu-central-1.amazonaws.com/prod/contact">
```

Replace `YOUR-API-ID` with the actual API Gateway URL from terraform output.

---

## Step 7: Test Locally

```bash
# Rebuild Jekyll
bundle exec jekyll build

# Serve locally
bundle exec jekyll serve --host 0.0.0.0

# Visit: http://localhost:4000/contact
# Fill out form and submit
```

Check hello@joshuafenech.de for the email!

---

## Step 8: Deploy to Production

```bash
git add lambda_contact_form.py lambda_contact_form.zip contact-form-terraform.tf _layouts/default.html
git commit -m "Add AWS Lambda contact form with SES"
git push origin website-updates

# Then merge to main
git checkout main
git merge website-updates
git push origin main
```

---

## Testing Checklist

After deployment:

- [ ] Visit https://d2ij5nb8hbhpx1.cloudfront.net/contact
- [ ] Fill out contact form
- [ ] Submit
- [ ] See success message
- [ ] Receive email at hello@joshuafenech.de
- [ ] Reply-to should be sender's email

---

## Troubleshooting

### Email not verified
```bash
# Check status
aws ses get-identity-verification-attributes \
  --identities hello@joshuafenech.de \
  --region eu-central-1

# Should show: "VerificationStatus": "Success"
```

### Form submission fails
```bash
# Check Lambda logs
aws logs tail /aws/lambda/my-portfolio-2026-abc123-contact-form --follow

# Test Lambda directly
aws lambda invoke \
  --function-name my-portfolio-2026-abc123-contact-form \
  --payload '{"httpMethod":"POST","body":"name=Test&email=test@example.com&message=Hello"}' \
  response.json

cat response.json
```

### API Gateway errors
```bash
# Check API Gateway logs (if enabled)
aws logs tail /aws/apigateway/my-portfolio-2026-abc123-contact-api --follow
```

---

## Cost Estimate

- **SES:** $0.10 per 1,000 emails (first 62,000/month free if sent from EC2)
- **Lambda:** First 1 million requests/month free
- **API Gateway:** First 1 million requests/month free
- **Expected monthly cost:** $0.00 - $0.10 (unless you get 1000+ submissions)

---

## SES Sandbox Limits

**Initially, SES is in SANDBOX mode:**
- Can only send TO verified email addresses
- Limit: 200 emails/day, 1 email/second

**For production (send to ANY email):**
```bash
# Request production access (via AWS Console)
# SES → Account dashboard → Request production access
```

But for **receiving** contact form submissions at hello@joshuafenech.de, sandbox is fine!

---

## Security Notes

- Form action is public API endpoint (expected)
- No authentication needed (public contact form)
- Rate limiting via API Gateway (default: 10,000 req/sec)
- Consider adding reCAPTCHA later to prevent spam
- CloudWatch logs all submissions

---

## Next Steps (Optional)

1. **Add reCAPTCHA** - Prevent spam submissions
2. **Enable API Gateway logging** - Better debugging
3. **Add email template** - prettier HTML emails
4. **Add auto-responder** - confirm receipt to sender
5. **Add DynamoDB** - Store submissions as backup

---

## Files Created

```
lambda_contact_form.py          # Lambda function code
lambda_contact_form.zip         # Deployment package
contact-form-terraform.tf       # Infrastructure as Code
```

---

**Ready to deploy? Start with Step 1!**
