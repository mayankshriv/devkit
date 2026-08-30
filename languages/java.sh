#!/bin/bash
# Java setup - jenv + JDKs
# Run: ./languages/java.sh

set -e

echo "==> Setting up Java environment..."

# Install jenv if not present
if ! command -v jenv &>/dev/null; then
  echo "  Installing jenv..."
  brew install jenv
fi

# Initialize jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Register installed JDKs with jenv
echo "  Registering JDKs with jenv..."
for jdk_dir in /Library/Java/JavaVirtualMachines/*/Contents/Home; do
  if [ -d "$jdk_dir" ]; then
    jenv add "$jdk_dir" 2>/dev/null || true
    echo "    Registered: $jdk_dir"
  fi
done

# Set default JDK (prefer latest LTS, fallback to older)
if jenv versions 2>/dev/null | grep -q "25"; then
  jenv global 25
  echo "  Default JDK set to 25"
elif jenv versions 2>/dev/null | grep -q "21"; then
  jenv global 21
  echo "  Default JDK set to 21"
elif jenv versions 2>/dev/null | grep -q "17"; then
  jenv global 17
  echo "  Default JDK set to 17"
fi

echo "  Java setup complete."
jenv versions
