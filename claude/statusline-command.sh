#!/bin/sh
# Claude Code statusline - shows model, cost, tokens, context, git state, diff stats
# Configured in settings.json: "statusLine": {"type": "command", "command": "sh ~/.claude/statusline-command.sh"}

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')

in_tok=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
out_tok=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
fmt_tok() {
  if [ "$1" -ge 1000000 ]; then
    printf '%.1fm' "$(echo "$1 / 1000000" | bc -l)"
  elif [ "$1" -ge 1000 ]; then
    printf '%.1fk' "$(echo "$1 / 1000" | bc -l)"
  else
    echo "$1"
  fi
}
in_fmt=$(fmt_tok "$in_tok")
out_fmt=$(fmt_tok "$out_tok")
cost_fmt=$(printf '$%.2f' "$cost")

branch=""
dirty=""
if [ -n "$cwd" ] && [ -e "$cwd/.git" ]; then
  branch=$(git --git-dir="$cwd/.git" --work-tree="$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$(git --git-dir="$cwd/.git" --work-tree="$cwd" status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
fi

parts=""
[ -n "$model" ] && parts="$model"
parts="$parts | ${cost_fmt}"
parts="$parts | ${in_fmt}in/${out_fmt}out | ctx:${ctx_pct}%"
[ -n "$branch" ] && parts="$parts | ${branch}${dirty}"
[ "$added" != "0" ] || [ "$removed" != "0" ] && parts="$parts | +${added}/-${removed}"

echo "$parts"
