#!/bin/bash
set -euo pipefail

PLUGIN_NAME="ship"
PLUGIN_KEY="$PLUGIN_NAME@local"
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

# Register in installed_plugins.json (plugins.<key>)
if [ -f "$INSTALLED_PLUGINS_FILE" ]; then
  python3 - "$INSTALLED_PLUGINS_FILE" "$PLUGIN_KEY" "$INSTALL_DIR" "$PLUGIN_VERSION" <<'PY'
import json, re, sys
from datetime import datetime, timezone

path, key, install_dir, version = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open(path) as f:
    raw = f.read()
data = json.loads(raw)

# Match the file's existing indentation so we don't reformat the whole file.
m = re.search(r'\n([ \t]+)"', raw)
indent = m.group(1) if m else "    "

now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z")
data.setdefault("plugins", {})[key] = [{
    "scope": "user",
    "installPath": install_dir,
    "version": version,
    "installedAt": now,
    "lastUpdated": now,
}]
with open(path, "w") as f:
    json.dump(data, f, indent=indent)
    f.write("\n")
PY
  echo "  Registered in installed_plugins.json"
else
  echo "  installed_plugins.json not found (skipped registration)"
fi

# Enable in settings.json (enabledPlugins.<key>)
if [ -f "$SETTINGS_FILE" ]; then
  python3 - "$SETTINGS_FILE" "$PLUGIN_KEY" <<'PY'
import json, re, sys

path, key = sys.argv[1], sys.argv[2]
with open(path) as f:
    raw = f.read()
data = json.loads(raw)

# Match the file's existing indentation so we don't reformat the whole file.
m = re.search(r'\n([ \t]+)"', raw)
indent = m.group(1) if m else "  "

data.setdefault("enabledPlugins", {})[key] = True
with open(path, "w") as f:
    json.dump(data, f, indent=indent)
    f.write("\n")
PY
  echo "  Enabled in settings.json"
else
  echo "  settings.json not found (skipped enable)"
fi

echo "Done. Restart Claude Code to activate the /ship command."
