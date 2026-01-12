# Git Safety Checklist

## ✅ What's SAFE to commit to Git

### Infrastructure Code
- ✅ `main.tf` - Terraform infrastructure code
- ✅ `terraform.tfvars.example` - Template for configuration
- ✅ `.devcontainer/` - Dev container configuration
- ✅ `.gitignore` - Git ignore rules

### Website Files
- ✅ `index.html` - Your website HTML
- ✅ Any CSS/JS files you create
- ✅ Images and assets (be mindful of file sizes)

### Documentation
- ✅ `README.md`, `QUICKSTART.md` - Documentation
- ✅ `setup.sh` - Setup scripts

## ❌ NEVER commit to Git

### Secrets & Credentials
- ❌ `terraform.tfvars` - Your actual config (bucket names, etc.)
- ❌ `.aws/` directory - AWS credentials
- ❌ `*.pem` files - SSH keys
- ❌ `.env` files - Environment variables

### Terraform State
- ❌ `*.tfstate` - Contains AWS resource IDs and sensitive data
- ❌ `*.tfstate.backup` - Backup state files
- ❌ `.terraform/` - Terraform working directory

**Why?** Terraform state contains:
- AWS account IDs
- Resource ARNs
- Potentially sensitive configuration values
- Internal AWS resource identifiers

## 🔒 How AWS Credentials Stay Safe

### Dev Container Setup
The dev container mounts `~/.aws/` from your host machine as **read-only**.

```json
"mounts": [
  "source=${localEnv:HOME}/.aws,target=/home/vscode/.aws,type=bind"
]
```

- ✅ Credentials never enter the container filesystem
- ✅ They're only accessible while container is running
- ✅ Not part of your project directory
- ✅ `.gitignore` blocks `.aws/` anyway (defense in depth)

## 🛡️ Best Practices

### Before Your First Commit

```bash
# 1. Verify .gitignore exists
cat .gitignore

# 2. Check what Git will track
git status

# 3. Look for sensitive files
git status | grep -E 'tfvars|tfstate|\.aws|\.pem|credentials'

# 4. If anything sensitive shows up, add it to .gitignore
```

### Safe Git Workflow

```bash
# Initialize repo
git init

# Check status (should NOT see .tfvars, .tfstate, .aws/)
git status

# Add safe files
git add .

# Verify what's staged
git diff --cached --name-only

# Commit
git commit -m "Initial commit: AWS portfolio infrastructure"

# Add remote
git remote add origin git@github.com:yourusername/aws-portfolio.git

# Push
git push -u origin main
```

### Double-Check Before Pushing

```bash
# See exactly what files are being committed
git diff --staged --name-only

# Or get full diff
git diff --staged

# Look for these patterns (should return nothing):
git diff --staged | grep -i "aws_access"
git diff --staged | grep -i "secret"
git diff --staged | grep -i "password"
```

## 🚨 What If You Accidentally Commit Secrets?

### If You Haven't Pushed Yet

```bash
# Remove the last commit but keep changes
git reset --soft HEAD~1

# Remove file from git but keep it locally
git rm --cached terraform.tfvars

# Commit again
git commit -m "Infrastructure code"
```

### If You Already Pushed

**This is serious - you need to:**

1. **Rotate credentials immediately** - Generate new AWS keys in IAM
2. **Remove from Git history** - Use BFG Repo Cleaner or git filter-branch
3. **Force push** - `git push --force` (only if repo is private)
4. **Consider repo as compromised** - Safest to delete and recreate

```bash
# Remove file from entire Git history (DESTRUCTIVE)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch terraform.tfvars" \
  --prune-empty --tag-name-filter cat -- --all

# Force push
git push origin --force --all
```

**Then immediately:**
- Go to AWS Console → IAM → Users → Security Credentials
- Delete the exposed access keys
- Generate new ones
- Run `aws configure` again

## 📋 Pre-Commit Checklist

Before every `git push`:

- [ ] No `*.tfvars` files (except `.example`)
- [ ] No `*.tfstate` files
- [ ] No `.aws/` directory
- [ ] No credentials or API keys in code
- [ ] No sensitive URLs or resource IDs in comments
- [ ] `.gitignore` is present and up to date

## 🔍 Automated Safety

### Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Check for sensitive files
if git diff --cached --name-only | grep -qE '\.tfvars$|\.tfstate|\.aws/|\.pem$|credentials'; then
    echo "❌ ERROR: Attempting to commit sensitive files!"
    echo "Files blocked:"
    git diff --cached --name-only | grep -E '\.tfvars$|\.tfstate|\.aws/|\.pem$|credentials'
    echo ""
    echo "Add these to .gitignore and try again."
    exit 1
fi

# Check for common secret patterns
if git diff --cached | grep -qiE 'aws_access_key_id|aws_secret_access_key|password.*=|secret.*='; then
    echo "❌ ERROR: Possible secrets detected in staged changes!"
    echo "Review your changes carefully."
    exit 1
fi

echo "✅ Pre-commit checks passed"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## 📦 What Your Repository Should Look Like

```
your-repo/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── README.md
├── .gitignore              ✅ Committed
├── index.html              ✅ Committed
├── main.tf                 ✅ Committed
├── terraform.tfvars.example ✅ Committed
├── README.md               ✅ Committed
├── QUICKSTART.md           ✅ Committed
├── setup.sh                ✅ Committed
│
├── terraform.tfvars        ❌ NOT in Git (.gitignore blocks it)
├── .terraform/             ❌ NOT in Git (.gitignore blocks it)
├── terraform.tfstate       ❌ NOT in Git (.gitignore blocks it)
└── .aws/                   ❌ NOT in Git (never in project dir anyway)
```

## 🎓 Summary

**The key principle:** 
> Infrastructure code = ✅ Safe to share
> 
> Infrastructure state & credentials = ❌ Never share

Your setup is designed to be Git-safe by default. The `.gitignore` file protects you, but always verify with `git status` before committing.

**When in doubt, don't commit it!**
