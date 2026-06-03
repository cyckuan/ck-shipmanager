---
name: install
description: Install or deploy a Claude Code plugin using physical file copies (not symlinks). Use when the user asks to "install plugin", "deploy plugin", "set up plugin locally", or needs to install/reinstall a plugin from source. Favours cp -r over ln -s for cross-OS reliability.
argument-hint: "[plugin-path]"
allowed-tools: ["Bash", "Read", "Write", "Edit"]
---

# Install Plugin

Install a Claude Code plugin from source using physical file copies. Never use symlinks — they break on Windows, inside containers, and when source paths move.

## Why Physical Copies

- Symlinks fail on Windows without Developer Mode or elevated privileges
- Symlinks break when the source repo is moved, deleted, or re-cloned elsewhere
- Containers and CI environments often don't support symlinks across mount boundaries
- Physical copies make the install self-contained and portable

## Installation Sequence

### Step 1: Locate Source

If a path argument is provided, use it. Otherwise look for a plugin in the current directory:

```bash
# Check for .claude-plugin/plugin.json in the given path or cwd
PLUGIN_SRC="${1:-.}"
if [ ! -f "$PLUGIN_SRC/.claude-plugin/plugin.json" ]; then
  echo "Error: no plugin.json found at $PLUGIN_SRC/.claude-plugin/plugin.json"
  exit 1
fi
```

Read `plugin.json` to get the plugin name and version.

### Step 2: Determine Install Target

```bash
PLUGIN_NAME="<name from plugin.json>"
INSTALL_DIR="$HOME/.claude/plugins/local/$PLUGIN_NAME"
```

### Step 3: Clean Previous Installation

Remove any existing installation — whether it's a directory, symlink, or stale copy:

```bash
if [ -L "$INSTALL_DIR" ]; then
  rm -f "$INSTALL_DIR"
elif [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
fi
```

### Step 4: Copy Plugin Files

Use `cp -r` for all plugin components. Never `ln -s`.

```bash
mkdir -p "$INSTALL_DIR"
cp -r "$PLUGIN_SRC/.claude-plugin" "$INSTALL_DIR/"

# Copy each component directory that exists
for dir in skills commands agents hooks scripts output-styles themes monitors bin; do
  [ -d "$PLUGIN_SRC/$dir" ] && cp -r "$PLUGIN_SRC/$dir" "$INSTALL_DIR/"
done

# Copy root-level files
for file in LICENSE README.md CHANGELOG.md settings.json .mcp.json .lsp.json; do
  [ -f "$PLUGIN_SRC/$file" ] && cp "$PLUGIN_SRC/$file" "$INSTALL_DIR/"
done
```

### Step 5: Register Plugin

Register in `~/.claude/plugins/installed_plugins.json`:

```bash
# Add entry: "plugin-name@local" with installPath, version, timestamps
```

Enable in `~/.claude/settings.json`:

```bash
# Set enabledPlugins["plugin-name@local"] = true
```

### Step 6: Validate

Run validation if `claude` CLI is available:

```bash
claude plugin validate "$INSTALL_DIR" 2>/dev/null || true
```

### Step 7: Report

```
Installed: <plugin-name> v<version> → ~/.claude/plugins/local/<plugin-name>
```

Remind user to restart Claude Code or run `/reload-plugins`.

## Cross-OS Notes

- Use `cp -r` (works on macOS, Linux, Windows Git Bash, WSL)
- Never use `ln -s` — it requires elevated privileges on Windows
- Use `date -u +"%Y-%m-%dT%H:%M:%S.000Z"` for timestamps (POSIX-compatible)
- Quote all paths containing `$HOME` or variables (spaces in Windows usernames)
- Make hook scripts executable: `chmod +x` (no-op on Windows but harmless)

## Uninstallation

To uninstall, reverse the process:

1. Remove `$INSTALL_DIR`
2. Remove entry from `installed_plugins.json`
3. Remove entry from `settings.json` `enabledPlugins`
4. Optionally remove per-project state: `rm <project>/.claude/<plugin-name>.local.json`
