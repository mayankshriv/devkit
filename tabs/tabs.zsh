# devkit tabs - herdr/tmux-based named tabs
# Sourced by devkit.zsh - do not source directly

# User config in ~/.config survives repo deletion; fall back to in-repo copy
if [[ -f "$HOME/.config/devkit/tabs.yaml" ]]; then
  DEVKIT_TABS_CONFIG="$HOME/.config/devkit/tabs.yaml"
else
  DEVKIT_TABS_CONFIG="${DEVKIT_DIR:-$HOME/devkit}/tabs/tabs.yaml"
fi
DEVKIT_TABS_TMUX_CONF="${DEVKIT_DIR:-$HOME/devkit}/tmux/tmux.conf"

# Launch or reattach to tabs
tabs() {
  # Prefer herdr if available
  if command -v herdr &>/dev/null; then
    if command -v herdr-spreader &>/dev/null && [[ -f "$DEVKIT_TABS_CONFIG" ]]; then
      herdr-spreader apply --file "$DEVKIT_TABS_CONFIG"
    else
      herdr
    fi
    return
  fi

  # Fallback to tmux
  if tmux has-session -t tabs 2>/dev/null; then
    tmux attach -t tabs
    return
  fi

  if [[ ! -f "$DEVKIT_TABS_CONFIG" ]]; then
    echo "No tabs configured. Copy the example:"
    echo "  mkdir -p ~/.config/devkit"
    echo "  cp ${DEVKIT_DIR:-~/devkit}/tabs/tabs.example.yaml ~/.config/devkit/tabs.yaml"
    return 1
  fi

  # Parse YAML and create tmux windows
  # Expects format: - name: <name>\n    root: <dir>
  local first=true
  local name dir
  while IFS= read -r line; do
    if [[ "$line" =~ '- name: '(.+) ]]; then
      name="${match[1]}"
    elif [[ "$line" =~ 'root: '(.+) ]]; then
      dir="${match[1]/#\~/$HOME}"
      if $first; then
        tmux -f "$DEVKIT_TABS_TMUX_CONF" new-session -d -s tabs -n "$name" -c "$dir" "claude; exec $SHELL"
        first=false
      else
        tmux new-window -t tabs -n "$name" -c "$dir" "claude; exec $SHELL"
      fi
    fi
  done < "$DEVKIT_TABS_CONFIG"

  if $first; then
    echo "No tabs found in $DEVKIT_TABS_CONFIG"
    return 1
  fi

  # Select first window and attach
  tmux select-window -t tabs:0
  tmux attach -t tabs
}

# List active tabs
tabls() {
  if command -v herdr &>/dev/null; then
    herdr list 2>/dev/null || echo "No active tabs. Run: tabs"
    return
  fi
  tmux list-windows -t tabs -F '  #I: #W  #{window_active} #{pane_current_path}' 2>/dev/null | \
    sed 's/ 1 / <- here  /; s/ 0 /        /' || echo "No active tabs. Run: tabs"
}

# Add a tab on the fly: tabadd <name> [directory]
tabadd() {
  local name="$1"
  local dir="${2:-$PWD}"
  if [[ -z "$name" ]]; then
    echo "Usage: tabadd <name> [directory]"
    return 1
  fi
  if command -v herdr &>/dev/null; then
    herdr workspace create "$name" --cwd "$dir" 2>/dev/null
    return
  fi
  if ! tmux has-session -t tabs 2>/dev/null; then
    echo "No active tabs. Run: tabs"
    return 1
  fi
  if tmux list-windows -t tabs -F '#W' | grep -qx "$name"; then
    echo "Tab '$name' already exists"
    return 1
  fi
  tmux new-window -t tabs -n "$name" -c "$dir"
  echo "Added tab '$name' -> $dir"
}

# Remove a tab: tabrm <name>
tabrm() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: tabrm <name>"
    return 1
  fi
  if command -v herdr &>/dev/null; then
    herdr workspace remove "$name" 2>/dev/null && echo "Removed tab '$name'" || echo "Tab '$name' not found"
    return
  fi
  if ! tmux has-session -t tabs 2>/dev/null; then
    echo "No active tabs. Run: tabs"
    return 1
  fi
  if ! tmux list-windows -t tabs -F '#W' | grep -qx "$name"; then
    echo "Tab '$name' not found"
    return 1
  fi
  tmux kill-window -t "tabs:$name"
  echo "Removed tab '$name'"
}

# Stop all tabs
taboff() {
  if command -v herdr &>/dev/null; then
    herdr server stop 2>/dev/null && echo "All tabs stopped" || echo "No active tabs"
    return
  fi
  tmux kill-session -t tabs 2>/dev/null && echo "All tabs stopped" || echo "No active tabs"
}
