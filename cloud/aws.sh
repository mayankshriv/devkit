#!/bin/bash
# AWS CLI setup
# Run: ./cloud/aws.sh

set -e

echo "==> Setting up AWS CLI..."

if ! command -v aws &>/dev/null; then
  echo "  Installing AWS CLI..."
  brew install awscli
fi

# Configure default profile if not set
if [ ! -f "$HOME/.aws/config" ]; then
  echo "  Running initial AWS configuration..."
  echo "  (Set your default region, output format, and credentials)"
  aws configure
else
  echo "  [skip] ~/.aws/config exists"
fi

echo ""
echo "  AWS CLI setup complete."
echo "  Useful commands:"
echo "    aws configure list-profiles    # list configured profiles"
echo "    aws sts get-caller-identity    # verify credentials"
echo "    aws configure sso              # set up SSO access"
aws --version
