# devkit - source this from ~/.zshrc
# Usage: source ~/devkit/shell/devkit.zsh

DEVKIT_DIR="${0:a:h:h}"

# -------------------------------------------------------------------
# Prompt with git branch
# -------------------------------------------------------------------
function git_branch_name() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo "($branch)"
  fi
}

setopt prompt_subst
prompt='%n@%m %.:$(git_branch_name) > '

# -------------------------------------------------------------------
# Completions
# -------------------------------------------------------------------
# zsh-completions from Homebrew
if [[ -d "/opt/homebrew/share/zsh-completions" ]]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

autoload -Uz compinit && compinit

# kubectl completions
[[ -x "$(command -v kubectl)" ]] && source <(kubectl completion zsh)

# gcloud completions (Homebrew cask location)
local gcloud_inc="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
[[ -f "$gcloud_inc/completion.zsh.inc" ]] && source "$gcloud_inc/completion.zsh.inc"
[[ -f "$gcloud_inc/path.zsh.inc" ]] && source "$gcloud_inc/path.zsh.inc"

# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------
source "$DEVKIT_DIR/shell/aliases.zsh"

# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------
source "$DEVKIT_DIR/shell/functions.zsh"

# -------------------------------------------------------------------
# Environment (secrets, API keys - gitignored)
# -------------------------------------------------------------------
[[ -f "$DEVKIT_DIR/shell/env.local" ]] && source "$DEVKIT_DIR/shell/env.local"

# -------------------------------------------------------------------
# PATH additions
# -------------------------------------------------------------------
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# -------------------------------------------------------------------
# NVM
# -------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# -------------------------------------------------------------------
# jenv
# -------------------------------------------------------------------
if [[ -d "$HOME/.jenv/bin" ]]; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# -------------------------------------------------------------------
# Default JDK (set DEVKIT_JDK_DEFAULT in env.local, e.g. DEVKIT_JDK_DEFAULT=21)
# -------------------------------------------------------------------
if [[ -n "$DEVKIT_JDK_DEFAULT" ]]; then
  jdk "$DEVKIT_JDK_DEFAULT" >/dev/null 2>&1
fi

# -------------------------------------------------------------------
# Tabs (herdr/tmux)
# -------------------------------------------------------------------
source "$DEVKIT_DIR/tabs/tabs.zsh"
