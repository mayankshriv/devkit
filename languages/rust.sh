#!/bin/bash
# Rust setup - rustup
# Run: ./languages/rust.sh

set -e

echo "==> Setting up Rust environment..."

if ! command -v rustup &>/dev/null; then
  echo "  Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Update to latest stable
rustup update stable

echo "  Rust setup complete."
rustc --version
cargo --version
