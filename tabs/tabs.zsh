# devkit tabs - herdr/tmux-based named tabs
# Sourced by devkit.zsh - do not source directly

# User config in ~/.config survives repo deletion; fall back to in-repo copy
if [[ -f "$HOME/.config/devkit/tabs.yaml" ]]; then
  DEVKIT_TABS_CONFIG="$HOME/.config/devkit/tabs.yaml"
else
  DEVKIT_TABS_CONFIG="${DEVKIT_DIR:-$HOME/devkit}/tabs/tabs.yaml"
fi
DEVKIT_TABS_TMUX_CONF="${DEVKIT_DIR:-$HOME/devkit}/tmux/tmux.conf"

# Parse workspace names from tabs.yaml
_devkit_tabs_names() {
  grep '^\s*- name:' "$DEVKIT_TABS_CONFIG" 2>/dev/null | sed 's/.*- name: *//'
}

# Resolve which backend to use: explicit flag > default (tmux)
_devkit_tabs_backend() {
  case "$1" in
    -herdr|--herdr)
      if ! command -v herdr &>/dev/null; then
        echo "herdr is not installed. Install with: brew install herdr" >&2
        return 1
      fi
      echo "herdr" ;;
    -tmux|--tmux)
      echo "tmux" ;;
    "")
      # Default to herdr (survives lid close), fall back to tmux
      if command -v herdr &>/dev/null; then
        echo "herdr"
      else
        echo "tmux"
      fi ;;
    *)
      echo "Usage: tabs [-tmux|-herdr]" >&2
      return 1 ;;
  esac
}

# Ensure each workspace has its configured agent running (idempotent).
# Handles post-restart: herdr restores workspaces but agents may fail to
# resume (stale session ID). This function detects agentless panes, sends
# Enter to dismiss any error output, waits for a shell prompt, then starts
# the configured command fresh.
_devkit_tabs_ensure_agents() {
  # Workspace IDs that already have a running agent
  local agent_ws
  agent_ws=$(herdr agent list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data.get('result', {}).get('agents', []):
    print(a.get('workspace_id', ''))
" 2>/dev/null)

  # Map: label -> workspace_id, workspace_id -> pane_id
  local ws_map pane_map
  ws_map=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for w in data.get('result', {}).get('workspaces', []):
    print(w.get('label', '') + '\t' + w.get('workspace_id', ''))
" 2>/dev/null)

  pane_map=$(herdr pane list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data.get('result', {}).get('panes', []):
    print(p.get('workspace_id', '') + '\t' + p.get('pane_id', ''))
" 2>/dev/null)

  # Walk the config; for each workspace+command pair, start if no agent
  local name cmd
  while IFS= read -r line; do
    if [[ "$line" =~ '- name: '(.+) ]]; then
      name="${match[1]}"
      cmd=""
    elif [[ "$line" =~ 'command: '(.+) ]]; then
      cmd="${match[1]}"
    fi

    if [[ -n "$name" && -n "$cmd" ]]; then
      local ws_id pane_id
      ws_id=$(echo "$ws_map" | awk -F'\t' -v n="$name" '$1==n {print $2; exit}')
      if [[ -n "$ws_id" ]] && ! echo "$agent_ws" | grep -qx "$ws_id"; then
        pane_id=$(echo "$pane_map" | awk -F'\t' -v w="$ws_id" '$1==w {print $2; exit}')
        if [[ -n "$pane_id" ]]; then
          # Dismiss any failed resume output and wait for shell prompt
          herdr pane send-keys "$pane_id" Enter 2>/dev/null
          sleep 1
          # Start the agent fresh
          herdr agent start "$name" --kind claude --pane "$pane_id" --timeout 15000 2>/dev/null
        fi
      fi
      cmd=""
    fi
  done < "$DEVKIT_TABS_CONFIG"
}

# --- herdr backend ---

_devkit_tabs_herdr() {
  # Already inside herdr
  if [[ "${HERDR_ENV:-}" == "1" ]]; then
    echo "Already in herdr. Switch workspaces with Alt+1-9 or Ctrl+B w"
    return
  fi

  # Start server if not running
  if ! pgrep -f "herdr server" &>/dev/null; then
    herdr server &>/dev/null &
    sleep 1
  fi

  # Get existing workspace labels for idempotency
  local existing_labels
  existing_labels=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for w in data.get('result', {}).get('workspaces', []):
    print(w.get('label', ''))
" 2>/dev/null)

  # Only create workspaces that don't already exist
  local needs_setup=false
  while IFS= read -r wname; do
    if ! echo "$existing_labels" | grep -qx "$wname"; then
      needs_setup=true
      break
    fi
  done < <(_devkit_tabs_names)

  if $needs_setup; then
    local name dir focus_name
    while IFS= read -r line; do
      if [[ "$line" =~ '- name: '(.+) ]]; then
        name="${match[1]}"
      elif [[ "$line" =~ 'root: '(.+) ]]; then
        dir="${match[1]/#\~/$HOME}"
        # Skip if this workspace already exists
        if echo "$existing_labels" | grep -qx "$name"; then
          continue
        fi
        # Create workspace and extract pane_id from response
        local pane_id
        pane_id=$(herdr workspace create --label "$name" --cwd "$dir" --no-focus 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('result', {}).get('root_pane', {}).get('pane_id', ''))
" 2>/dev/null)
        # Run claude in the pane
        if [[ -n "$pane_id" ]]; then
          herdr pane run "$pane_id" claude 2>/dev/null
        fi
      elif [[ "$line" =~ 'focus: true' && -n "$name" ]]; then
        focus_name="$name"
      fi
    done < "$DEVKIT_TABS_CONFIG"

    # Close the default ~ workspace
    local default_id
    default_id=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
ws = [w for w in data.get('result', {}).get('workspaces', []) if w.get('label') == '~']
print(ws[0]['workspace_id'] if ws else '')
" 2>/dev/null)
    [[ -n "$default_id" ]] && herdr workspace close "$default_id" 2>/dev/null

    # Focus the designated workspace
    if [[ -n "$focus_name" ]]; then
      local focus_id
      focus_id=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
ws = [w for w in data.get('result', {}).get('workspaces', []) if w.get('label') == '$focus_name']
print(ws[0]['workspace_id'] if ws else '')
" 2>/dev/null)
      [[ -n "$focus_id" ]] && herdr workspace focus "$focus_id" 2>/dev/null
    fi
  fi

  # Ensure agents are running in all workspaces (handles server restart)
  _devkit_tabs_ensure_agents

  # Attach to herdr UI
  herdr
}

# --- tmux backend ---

_devkit_tabs_tmux() {
  # Reattach if session exists
  if tmux has-session -t tabs 2>/dev/null; then
    tmux attach -t tabs
    return
  fi

  # Parse YAML and create tmux windows
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

# --- Main entry points ---

# Launch or reattach to tabs
tabs() {
  if [[ ! -f "$DEVKIT_TABS_CONFIG" ]]; then
    echo "No tabs configured. Copy the example:"
    echo "  mkdir -p ~/.config/devkit"
    echo "  cp ${DEVKIT_DIR:-~/devkit}/tabs/tabs.example.yaml ~/.config/devkit/tabs.yaml"
    return 1
  fi

  local backend
  backend=$(_devkit_tabs_backend "$1") || return 1

  case "$backend" in
    herdr) _devkit_tabs_herdr ;;
    tmux)  _devkit_tabs_tmux ;;
  esac
}

# List active tabs
tabls() {
  if pgrep -f "herdr server" &>/dev/null; then
    herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for w in data.get('result', {}).get('workspaces', []):
    if w.get('label') == '~': continue
    marker = ' <- here' if w.get('focused') else ''
    agent = w.get('agent_status', '')
    print(f\"  {w['number']}: {w['label']}  [{agent}]{marker}\")
" 2>/dev/null || echo "No active tabs. Run: tabs"
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
  if pgrep -f "herdr server" &>/dev/null; then
    herdr workspace create --label "$name" --cwd "$dir" 2>/dev/null
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
  if pgrep -f "herdr server" &>/dev/null; then
    local ws_id
    ws_id=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
ws = [w for w in data.get('result', {}).get('workspaces', []) if w.get('label') == '$name']
print(ws[0]['workspace_id'] if ws else '')
" 2>/dev/null)
    if [[ -n "$ws_id" ]]; then
      herdr workspace close "$ws_id" 2>/dev/null && echo "Removed tab '$name'"
    else
      echo "Tab '$name' not found"
    fi
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
  if pgrep -f "herdr server" &>/dev/null; then
    herdr server stop 2>/dev/null && echo "All tabs stopped" || echo "No active tabs"
    return
  fi
  tmux kill-session -t tabs 2>/dev/null && echo "All tabs stopped" || echo "No active tabs"
}
