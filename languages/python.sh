#!/bin/bash
# Python setup - pyenv + uv
# Run: ./languages/python.sh

set -e

echo "==> Setting up Python environment..."

# pyenv
if ! command -v pyenv &>/dev/null; then
  echo "  Installing pyenv..."
  brew install pyenv
fi

# Install latest stable Python via pyenv
echo "  Installing latest Python..."
latest=$(pyenv install --list | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
pyenv install -s "$latest"
pyenv global "$latest"

# uv (modern Python package manager)
if ! command -v uv &>/dev/null; then
  echo "  Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

echo "  Python setup complete."
python3 --version
