#!/bin/bash
# Node.js setup - nvm
# Run: ./languages/node.sh

set -e

echo "==> Setting up Node.js environment..."

# Install nvm if not present
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  echo "  Installing nvm..."
  brew install nvm
  mkdir -p "$NVM_DIR"
fi

# Load nvm
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Install latest LTS
echo "  Installing latest LTS Node..."
nvm install --lts
nvm alias default 'lts/*'

echo "  Node.js setup complete."
node --version
npm --version
