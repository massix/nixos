#!/bin/bash
# Claude Code statusLine command. Reads the per-event JSON from stdin.
input=$(cat)

model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
cwd=$(jq -r '.cwd // .workspace.current_dir // "?"' <<<"$input")
session_id=$(jq -r '.session_id // ""' <<<"$input")
cost=$(jq -r '.cost.total_cost_usd // 0' <<<"$input")

pwd_display="${cwd/#$HOME/~}"

branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
fi

cost_fmt=$(printf '$%.2f' "$cost")

# In-flight background tasks for this session: the daemon keys job state
# dirs by the short id, which is the leading segment of session_id.
short_id="${session_id%%-*}"
job_state="$HOME/.claude/jobs/$short_id/state.json"
active_tasks=0
if [ -f "$job_state" ]; then
  in_flight=$(jq -r '.inFlight.tasks // 0' "$job_state" 2>/dev/null)
  queued=$(jq -r '.inFlight.queued // 0' "$job_state" 2>/dev/null)
  active_tasks=$((in_flight + queued))
fi

# Remaining (non-completed) TaskCreate/TaskList todo items for this session.
todo_dir="$HOME/.claude/tasks/$session_id"
todos_left=0
if [ -d "$todo_dir" ]; then
  for f in "$todo_dir"/*.json; do
    [ -e "$f" ] || continue
    status=$(jq -r '.status // "pending"' "$f" 2>/dev/null)
    if [ "$status" != "completed" ] && [ "$status" != "cancelled" ]; then
      todos_left=$((todos_left + 1))
    fi
  done
fi

# Colors
c_reset=$'\033[0m'
c_model=$'\033[36m'
c_path=$'\033[2m'
c_branch=$'\033[33m'
c_cost=$'\033[32m'
c_tasks=$'\033[35m'

line="${c_model}${model}${c_reset} ${c_path}${pwd_display}${c_reset}"
if [ -n "$branch" ]; then
  line="${line} ${c_branch}⎇ ${branch}${c_reset}"
fi
line="${line} ${c_cost}${cost_fmt}${c_reset} ${c_tasks}⚙ ${active_tasks}${c_reset} ${c_tasks}☐ ${todos_left}${c_reset}"

echo "$line"
