#!/bin/bash
# Google Cloud SDK setup
# Run: ./cloud/gcloud.sh

set -e

echo "==> Setting up Google Cloud SDK..."

# Source gcloud if available
GCLOUD_INC="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -f "$GCLOUD_INC/path.zsh.inc" ]; then
  source "$GCLOUD_INC/path.zsh.inc"
fi

if ! command -v gcloud &>/dev/null; then
  echo "  Installing Google Cloud SDK..."
  brew install --cask google-cloud-sdk
fi

# Initialize if not configured
if ! gcloud config get-value project &>/dev/null 2>&1 || [ -z "$(gcloud config get-value project 2>/dev/null)" ]; then
  echo "  Running initial gcloud setup..."
  gcloud init
else
  echo "  [skip] gcloud already configured"
  echo "  Project: $(gcloud config get-value project 2>/dev/null)"
  echo "  Account: $(gcloud config get-value account 2>/dev/null)"
fi

# Application default credentials
if [ ! -f "$HOME/.config/gcloud/application_default_credentials.json" ]; then
  echo ""
  echo "  Set up application default credentials:"
  echo "    gcloud auth application-default login"
fi

echo ""
echo "  Google Cloud setup complete."
gcloud --version | head -1
