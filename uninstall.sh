#!/bin/bash
set -euo pipefail

PLUGIN_NAME="ship"
INSTALL_DIR="$HOME/.claude/plugins/local/$PLUGIN_NAME"
SETTINGS_FILE="$HOME/.claude/settings.json"
INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"

echo "Uninstalling $PLUGIN_NAME plugin..."

# Remove plugin files
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "  Removed $INSTALL_DIR"
elif [ -L "$INSTALL_DIR" ]; then
  rm -f "$INSTALL_DIR"
  echo "  Removed symlink $INSTALL_DIR"
else
  echo "  No installation found at $INSTALL_DIR"
fi

# Remove from installed_plugins.json
if [ -f "$INSTALLED_PLUGINS_FILE" ]; then
  UPDATED=$(python3 -c "
import json, sys
with open('$INSTALLED_PLUGINS_FILE') as f:
    data = json.load(f)
data.get('plugins', {}).pop('$PLUGIN_NAME@local', None)
json.dump(data, sys.stdout, indent=4)
")
  echo "$UPDATED" > "$INSTALLED_PLUGINS_FILE"
  echo "  Removed from installed_plugins.json"
fi

# Disable in settings.json
if [ -f "$SETTINGS_FILE" ]; then
  UPDATED=$(python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    data = json.load(f)
data.get('enabledPlugins', {}).pop('$PLUGIN_NAME@local', None)
json.dump(data, sys.stdout, indent=4)
")
  echo "$UPDATED" > "$SETTINGS_FILE"
  echo "  Removed from settings.json"
fi

echo "Done. Restart Claude Code to complete removal."
