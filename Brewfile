# devkit Brewfile - developer tools and applications
# Usage: brew bundle --file=~/devkit/Brewfile

# Taps
tap "homebrew/cask-versions"

# -------------------------------------------------------------------
# CLI essentials
# -------------------------------------------------------------------
brew "bat"                    # cat with syntax highlighting
brew "fd"                     # modern find
brew "fzf"                    # fuzzy finder
brew "ripgrep"                # fast grep (rg)
brew "jq"                     # JSON processor
brew "tree"                   # directory tree view

# -------------------------------------------------------------------
# Git and GitHub
# -------------------------------------------------------------------
brew "git"
brew "gh"                     # GitHub CLI
brew "git-filter-repo"        # repo history rewriting

# -------------------------------------------------------------------
# Terminal
# -------------------------------------------------------------------
brew "tmux"                   # terminal multiplexer (fallback)
# brew "herdr"                # agent-aware terminal multiplexer (uncomment when available via brew)

# -------------------------------------------------------------------
# Languages - Java
# -------------------------------------------------------------------
brew "maven"
brew "jenv"                   # Java version manager
cask "temurin"                # JDK latest LTS (25)
cask "temurin@21"
cask "temurin@17"
cask "temurin@11"
cask "zulu@8"                 # JDK 8

# -------------------------------------------------------------------
# Languages - Node
# -------------------------------------------------------------------
brew "node"
# nvm: installed via curl (see languages/node.sh), not brew - avoids conflicts
brew "pnpm"

# -------------------------------------------------------------------
# Languages - Python
# -------------------------------------------------------------------
brew "python@3.14"
brew "pyenv"                  # Python version manager
brew "pipx"                   # isolated Python CLI tools

# -------------------------------------------------------------------
# Languages - Rust
# -------------------------------------------------------------------
brew "rust"

# -------------------------------------------------------------------
# Build and data tools
# -------------------------------------------------------------------
brew "protobuf"
brew "graphviz"
brew "pandoc"                 # document converter
brew "tkdiff"                 # visual diff/merge tool

# -------------------------------------------------------------------
# Shell
# -------------------------------------------------------------------
brew "zsh-completions"        # extra zsh completions

# -------------------------------------------------------------------
# Cloud and infrastructure
# -------------------------------------------------------------------
brew "awscli"
brew "azure-cli"
brew "kubernetes-cli"         # kubectl
brew "docker"
brew "grpcurl"                # gRPC curl

# -------------------------------------------------------------------
# Other
# -------------------------------------------------------------------
brew "llvm"

# -------------------------------------------------------------------
# Cask applications
# -------------------------------------------------------------------
cask "claude-code"            # Claude Code CLI
cask "iterm2"                 # terminal emulator
cask "visual-studio-code"     # editor
cask "jdk-mission-control"    # JFR analysis
cask "google-cloud-sdk"       # gcloud CLI
