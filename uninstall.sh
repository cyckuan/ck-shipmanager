#!/bin/bash
set -euo pipefail

PLUGIN_NAME="ship"
PLUGIN_KEY="$PLUGIN_NAME@local"
INSTALL_DIR="$HOME/.claude/plugins/local/$PLUGIN_NAME"
SETTINGS_FILE="$HOME/.claude/settings.json"
INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"

echo "Uninstalling $PLUGIN_KEY..."

# Remove plugin files (directory or stray symlink)
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "  Removed $INSTALL_DIR"
elif [ -L "$INSTALL_DIR" ]; then
  rm -f "$INSTALL_DIR"
  echo "  Removed symlink $INSTALL_DIR"
else
  echo "  No installation found at $INSTALL_DIR"
fi

# Remove "<container>.$PLUGIN_KEY" from a JSON file, preserving its indentation.
# Echoes one of: removed | absent | no-file
remove_plugin_key() {
  local file="$1" container="$2"
  if [ ! -f "$file" ]; then
    echo "no-file"
    return
  fi
  python3 - "$file" "$container" "$PLUGIN_KEY" <<'PY'
import json, re, sys

path, container, key = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    raw = f.read()
data = json.loads(raw)

# Match the file's existing indentation so we don't reformat the whole file.
m = re.search(r'\n([ \t]+)"', raw)
indent = m.group(1) if m else "  "

removed = data.get(container, {}).pop(key, None) is not None
with open(path, "w") as f:
    json.dump(data, f, indent=indent)
    f.write("\n")

print("removed" if removed else "absent")
PY
}

# Unregister from installed_plugins.json (plugins.<key>)
case "$(remove_plugin_key "$INSTALLED_PLUGINS_FILE" plugins)" in
  removed) echo "  Unregistered from installed_plugins.json" ;;
  absent)  echo "  Not registered in installed_plugins.json" ;;
  no-file) echo "  installed_plugins.json not found" ;;
esac

# Disable in settings.json (enabledPlugins.<key>)
case "$(remove_plugin_key "$SETTINGS_FILE" enabledPlugins)" in
  removed) echo "  Disabled in settings.json" ;;
  absent)  echo "  Not enabled in settings.json" ;;
  no-file) echo "  settings.json not found" ;;
esac

echo "Done. Restart Claude Code to complete removal."
