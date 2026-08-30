#!/bin/bash
# Kubernetes CLI setup
# Run: ./cloud/kubectl.sh

set -e

echo "==> Setting up kubectl..."

if ! command -v kubectl &>/dev/null; then
  echo "  Installing kubectl..."
  brew install kubernetes-cli
fi

echo "  kubectl $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)"

# Check for contexts
if [ -f "$HOME/.kube/config" ]; then
  local_contexts=$(kubectl config get-contexts -o name 2>/dev/null | wc -l | tr -d ' ')
  echo "  Contexts configured: $local_contexts"
  echo "  Current context: $(kubectl config current-context 2>/dev/null || echo 'none')"
else
  echo "  No ~/.kube/config found."
  echo "  Add contexts with:"
  echo "    aws eks update-kubeconfig --name <cluster> --region <region> --profile <profile>"
  echo "    gcloud container clusters get-credentials <cluster> --region <region> --project <project>"
fi

echo ""
echo "  kubectl setup complete."
