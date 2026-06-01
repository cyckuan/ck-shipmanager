#!/bin/bash
set -euo pipefail

PLUGIN_NAME="ship"
PLUGIN_VERSION="0.1.0"
SOURCE_DIR="$(cd "$(dirname "$0")/ship-plugin" && pwd)"
INSTALL_DIR="$HOME/.claude/plugins/local/$PLUGIN_NAME"
SETTINGS_FILE="$HOME/.claude/settings.json"
INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"

echo "Installing $PLUGIN_NAME plugin v$PLUGIN_VERSION..."

# Verify source exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: source directory not found: $SOURCE_DIR"
  exit 1
fi

# Remove existing installation if present
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "  Removed previous installation"
fi

# Copy plugin files
mkdir -p "$INSTALL_DIR"
cp -r "$SOURCE_DIR"/.claude-plugin "$INSTALL_DIR/"
cp -r "$SOURCE_DIR"/hooks "$INSTALL_DIR/"
cp -r "$SOURCE_DIR"/skills "$INSTALL_DIR/"
cp -r "$SOURCE_DIR"/scripts "$INSTALL_DIR/"
[ -f "$SOURCE_DIR/LICENSE" ] && cp "$SOURCE_DIR/LICENSE" "$INSTALL_DIR/"
[ -f "$SOURCE_DIR/README.md" ] && cp "$SOURCE_DIR/README.md" "$INSTALL_DIR/"
echo "  Copied plugin files to $INSTALL_DIR"

# Register in installed_plugins.json
if [ -f "$INSTALLED_PLUGINS_FILE" ]; then
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
  UPDATED=$(python3 -c "
import json, sys
with open('$INSTALLED_PLUGINS_FILE') as f:
    data = json.load(f)
data.setdefault('plugins', {})['$PLUGIN_NAME@local'] = [{
    'scope': 'user',
    'installPath': '$INSTALL_DIR',
    'version': '$PLUGIN_VERSION',
    'installedAt': '$NOW',
    'lastUpdated': '$NOW'
}]
json.dump(data, sys.stdout, indent=4)
")
  echo "$UPDATED" > "$INSTALLED_PLUGINS_FILE"
  echo "  Registered in installed_plugins.json"
fi

# Enable in settings.json
if [ -f "$SETTINGS_FILE" ]; then
  UPDATED=$(python3 -c "
import json, sys
with open('$SETTINGS_FILE') as f:
    data = json.load(f)
data.setdefault('enabledPlugins', {})['$PLUGIN_NAME@local'] = True
json.dump(data, sys.stdout, indent=4)
")
  echo "$UPDATED" > "$SETTINGS_FILE"
  echo "  Enabled in settings.json"
fi

echo "Done. Restart Claude Code to activate the /ship command."
