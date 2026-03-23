#!/bin/bash
# Launch multiple Claude Code instances in parallel via tmux
#
# Usage:
#   bash scripts/parallel.sh                     # Launch 3 worktrees interactively
#   bash scripts/parallel.sh 5                   # Launch 5 worktrees
#   bash scripts/parallel.sh auth payments tests  # Named worktrees
#
# Each instance gets its own git worktree (isolated branch, no conflicts).
# Switch between them: tmux select-window -t claude-parallel:0
# Kill all: tmux kill-session -t claude-parallel

set -e

SESSION="claude-parallel"
PROJECT_DIR="${PWD}"

# Kill existing session if running
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Determine worktree names
if [ $# -eq 0 ]; then
  NAMES=("task-1" "task-2" "task-3")
elif [ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
  NAMES=()
  for i in $(seq 1 "$1"); do
    NAMES+=("task-$i")
  done
else
  NAMES=("$@")
fi

echo "🚀 Launching ${#NAMES[@]} parallel Claude instances..."
echo ""

# Create tmux session with first worktree
FIRST="${NAMES[0]}"
tmux new-session -d -s "$SESSION" -n "$FIRST" "cd $PROJECT_DIR && claude --worktree $FIRST"
echo "  ✅ $FIRST"

# Add remaining worktrees as new windows
for NAME in "${NAMES[@]:1}"; do
  tmux new-window -t "$SESSION" -n "$NAME" "cd $PROJECT_DIR && claude --worktree $NAME"
  echo "  ✅ $NAME"
done

echo ""
echo "All instances running in tmux session: $SESSION"
echo ""
echo "Commands:"
echo "  tmux attach -t $SESSION              # View all instances"
echo "  Ctrl-B then number (0,1,2...)        # Switch between instances"
echo "  Ctrl-B then d                        # Detach (instances keep running)"
echo "  tmux kill-session -t $SESSION        # Stop all instances"
echo ""

# Attach to the session
tmux attach -t "$SESSION"
