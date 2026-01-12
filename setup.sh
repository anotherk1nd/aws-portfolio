#!/bin/bash

# AWS Portfolio Dev Container Setup Script
# This script helps you organize your project files

echo "=== AWS Portfolio Project Setup ==="
echo ""

# Check if we're in the right directory
if [ -f "index.html" ] && [ -f "main.tf" ]; then
    echo "✓ Project files found in current directory"
else
    echo "⚠ Warning: Expected project files not found"
    echo "  Make sure you're in the directory with index.html and main.tf"
    echo ""
fi

# Check for .devcontainer
if [ -d ".devcontainer" ]; then
    echo "✓ Dev container configuration found"
else
    echo "✗ .devcontainer directory not found"
    echo "  Make sure you copied the .devcontainer folder here"
    exit 1
fi

# Check for terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    if [ -f "terraform.tfvars.example" ]; then
        echo ""
        read -p "Create terraform.tfvars from example? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp terraform.tfvars.example terraform.tfvars
            echo "✓ Created terraform.tfvars"
            echo "  Remember to edit it with your bucket name!"
        fi
    fi
else
    echo "✓ terraform.tfvars exists"
fi

# Check for AWS credentials
if [ -d "$HOME/.aws" ]; then
    echo "✓ AWS credentials directory found at ~/.aws"
else
    echo "⚠ AWS credentials not found at ~/.aws"
    echo "  Run 'aws configure' on your host machine before opening in container"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo ""
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Terraform
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars

# AWS
.aws/

# IDE
.vscode/
.idea/

# OS
.DS_Store
EOF
    echo "✓ Created .gitignore"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Open this folder in VS Code: code ."
echo "2. When prompted, click 'Reopen in Container'"
echo "3. Wait for container to build (2-5 minutes first time)"
echo "4. Edit terraform.tfvars with your bucket name"
echo "5. Edit index.html with your information"
echo "6. Run: terraform init && terraform apply"
echo ""
echo "See .devcontainer/README.md for detailed instructions"
