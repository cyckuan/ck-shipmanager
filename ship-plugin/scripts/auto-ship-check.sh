#!/bin/bash
set -euo pipefail

CONFIG_FILE="$CLAUDE_PROJECT_DIR/.claude/ship.local.json"

# If no config or autoship not enabled, approve stop normally
if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

enabled=$(jq -r '.autoship // false' "$CONFIG_FILE" 2>/dev/null)
if [ "$enabled" != "true" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# Check for uncommitted changes
changes=$(git status --porcelain 2>/dev/null)
if [ -z "$changes" ]; then
  echo '{"decision": "approve"}'
  exit 0
fi

# There are uncommitted changes and autoship is on — block stop so Claude ships first
echo '{"decision": "block", "reason": "Auto-ship is enabled and there are uncommitted changes. Execute the ship sequence (git add, commit with type:description format, pull --rebase, push) before stopping."}'
exit 0
