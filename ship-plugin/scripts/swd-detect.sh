#!/bin/bash
set -euo pipefail

PROMPT="${CLAUDE_USER_PROMPT:-}"
CONFIG_FILE="$CLAUDE_PROJECT_DIR/.claude/ship.local.json"

# Check if prompt ends with "swd" (case-insensitive, with optional trailing whitespace)
if echo "$PROMPT" | grep -qiE '\bswd\s*$'; then
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo '{"autoship": true, "oneshot": true}' > "$CONFIG_FILE"
  echo '{"decision": "approve"}'
else
  echo '{"decision": "approve"}'
fi
exit 0
