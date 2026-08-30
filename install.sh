#!/bin/bash
# devkit installer
# Usage: ./install.sh
#
# Idempotent - safe to run multiple times. Backs up existing files before symlinking.

set -e

DEVKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.devkit-backup/$(date +%Y%m%d-%H%M%S)"

echo "devkit - developer environment setup"
echo "====================================="
echo "Source: $DEVKIT_DIR"
echo ""

# -------------------------------------------------------------------
# Helper: symlink with backup
# -------------------------------------------------------------------
link_file() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
      echo "  [skip] $dst (already linked)"
      return
    fi
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    echo "  [backup] $dst -> $BACKUP_DIR/$(basename "$dst")"
  fi

  ln -sf "$src" "$dst"
  echo "  [link] $dst -> $src"
}

# -------------------------------------------------------------------
# 1. Homebrew
# -------------------------------------------------------------------
echo ""
echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
  echo "  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "  [skip] Homebrew already installed"
fi

echo "  Running brew bundle..."
brew bundle --file="$DEVKIT_DIR/Brewfile" --no-lock

# -------------------------------------------------------------------
# 2. Git config
# -------------------------------------------------------------------
echo ""
echo "==> Git"
mkdir -p "$HOME/.config/git"
link_file "$DEVKIT_DIR/git/ignore" "$HOME/.config/git/ignore"
chmod +x "$DEVKIT_DIR/git/hooks/pre-push"

# Set global hooks path
git config --global core.hooksPath "$DEVKIT_DIR/git/hooks"
echo "  [set] core.hooksPath -> $DEVKIT_DIR/git/hooks"

# Offer to include gitconfig (don't replace - user has their own name/email)
if ! git config --global --get include.path | grep -q "devkit" 2>/dev/null; then
  echo ""
  echo "  To include devkit git aliases and settings, run:"
  echo "    git config --global include.path '$DEVKIT_DIR/git/gitconfig'"
  echo "  (Skipped - your ~/.gitconfig has your name/email, we won't overwrite it)"
fi

# -------------------------------------------------------------------
# 3. SSH
# -------------------------------------------------------------------
echo ""
echo "==> SSH"
mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$DEVKIT_DIR/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  echo "  [copy] ~/.ssh/config"
else
  echo "  [skip] ~/.ssh/config exists"
fi

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo ""
  echo "  No SSH key found. Generate one with:"
  echo "    ssh-keygen -t ed25519 -C \"your-email@example.com\""
fi

# -------------------------------------------------------------------
# 4. tmux
# -------------------------------------------------------------------
echo ""
echo "==> tmux"
link_file "$DEVKIT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# -------------------------------------------------------------------
# 5. Claude Code
# -------------------------------------------------------------------
echo ""
echo "==> Claude Code"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.claude/.sk/lint"
mkdir -p "$HOME/.claude/.sk/dev-framework"

# Settings (merge-safe: don't overwrite if exists, user may have customized)
if [ ! -f "$HOME/.claude/settings.json" ]; then
  cp "$DEVKIT_DIR/claude/settings.json" "$HOME/.claude/settings.json"
  echo "  [copy] ~/.claude/settings.json"
else
  echo "  [skip] ~/.claude/settings.json exists (won't overwrite)"
  echo "         Compare with: diff ~/.claude/settings.json $DEVKIT_DIR/claude/settings.json"
fi

# CLAUDE.md
if [ ! -f "$HOME/.claude/CLAUDE.md" ]; then
  cp "$DEVKIT_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  echo "  [copy] ~/.claude/CLAUDE.md"
else
  echo "  [skip] ~/.claude/CLAUDE.md exists"
fi

# Statusline
cp "$DEVKIT_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
echo "  [copy] ~/.claude/statusline-command.sh"

# Skills
cp "$DEVKIT_DIR/claude/skills/lint/SKILL.md" "$HOME/.claude/.sk/lint/SKILL.md"
echo "  [copy] ~/.claude/.sk/lint/SKILL.md"
cp "$DEVKIT_DIR/claude/skills/dev-framework/SKILL.md" "$HOME/.claude/.sk/dev-framework/SKILL.md"
echo "  [copy] ~/.claude/.sk/dev-framework/SKILL.md"

# -------------------------------------------------------------------
# 6. herdr (agent-aware terminal multiplexer)
# -------------------------------------------------------------------
echo ""
echo "==> herdr"
if command -v herdr &>/dev/null; then
  echo "  [skip] herdr already installed"
else
  echo "  Installing herdr..."
  curl -fsSL https://herdr.dev/install.sh | sh || echo "  [warn] herdr install failed - tmux fallback will be used"
fi

# Install Claude integration
if command -v herdr &>/dev/null; then
  herdr integration install claude 2>/dev/null && echo "  [ok] Claude integration installed" || true
fi

# herdr-spreader
if ! command -v herdr-spreader &>/dev/null; then
  echo "  Installing herdr-spreader..."
  brew install herdr-spreader 2>/dev/null || echo "  [warn] herdr-spreader not in brew - install manually: cargo install herdr-spreader"
fi

# -------------------------------------------------------------------
# 7. Tabs config
# -------------------------------------------------------------------
echo ""
echo "==> Tabs"
if [ ! -f "$DEVKIT_DIR/tabs/tabs.yaml" ]; then
  echo "  No tabs.yaml found. Create one from the example:"
  echo "    cp $DEVKIT_DIR/tabs/tabs.example.yaml $DEVKIT_DIR/tabs/tabs.yaml"
  echo "  Then edit it with your project directories."
else
  echo "  [ok] tabs.yaml found"
fi

# -------------------------------------------------------------------
# 8. Languages (optional - run individually)
# -------------------------------------------------------------------
echo ""
echo "==> Languages"
echo "  Run these individually as needed:"
echo "    $DEVKIT_DIR/languages/java.sh"
echo "    $DEVKIT_DIR/languages/node.sh"
echo "    $DEVKIT_DIR/languages/python.sh"
echo "    $DEVKIT_DIR/languages/rust.sh"

chmod +x "$DEVKIT_DIR/languages/"*.sh

# -------------------------------------------------------------------
# 9. Cloud tools (optional - run individually)
# -------------------------------------------------------------------
echo ""
echo "==> Cloud"
echo "  Run these individually as needed:"
echo "    $DEVKIT_DIR/cloud/aws.sh       # AWS CLI setup"
echo "    $DEVKIT_DIR/cloud/gcloud.sh    # Google Cloud SDK setup"
echo "    $DEVKIT_DIR/cloud/kubectl.sh   # Kubernetes CLI setup"

chmod +x "$DEVKIT_DIR/cloud/"*.sh

# -------------------------------------------------------------------
# 10. iTerm2 profile
# -------------------------------------------------------------------
echo ""
echo "==> iTerm2"
echo "  Import the profile manually:"
echo "    iTerm2 > Settings > Profiles > Other Actions > Import JSON Profiles"
echo "    Select: $DEVKIT_DIR/terminal/iterm2-profile.json"

# -------------------------------------------------------------------
# 11. IntelliJ IDEA
# -------------------------------------------------------------------
echo ""
echo "==> IntelliJ IDEA"
echo "  Import code style manually:"
echo "    Settings > Editor > Code Style > Import Scheme > IntelliJ IDEA code style XML"
echo "    Select: $DEVKIT_DIR/intellij/codestyle.xml"
echo "  See: $DEVKIT_DIR/intellij/README.md"

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
echo ""
echo "====================================="
echo "devkit setup complete!"
echo ""
echo "Add this line to your ~/.zshrc:"
echo "  source $DEVKIT_DIR/shell/devkit.zsh"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "Backed up files are in: $BACKUP_DIR"
fi
echo ""
echo "Next steps:"
echo "  1. Add the source line above to ~/.zshrc"
echo "  2. Create your tabs.yaml (see tabs/tabs.example.yaml)"
echo "  3. Open a new terminal and run: tabs"
