---
name: package
description: Package a Claude Code plugin for release and marketplace submission. Use when the user asks to "package plugin", "prepare for release", "submit to marketplace", "publish plugin", "release plugin", or needs to audit plugin quality before submission. Validates cross-OS compatibility, security, required files, and Anthropic marketplace standards.
argument-hint: "[plugin-path]"
allowed-tools: ["Bash", "Read", "Write", "Edit"]
---

# Package Plugin for Release

Prepare a Claude Code plugin for high-quality release and Anthropic marketplace submission. This skill audits, fixes, and validates everything required.

## Packaging Checklist

Run through each section. Fix issues inline. Report a final summary.

---

### 1. Required Files Audit

Verify these files exist at the plugin root. Create missing ones.

| File | Required | Purpose |
|------|----------|---------|
| `.claude-plugin/plugin.json` | Yes | Plugin manifest |
| `README.md` | Yes | Installation, usage, uninstallation instructions |
| `LICENSE` | Yes | SPDX-compatible license file |
| `CHANGELOG.md` | Yes | Version history (required if using explicit versions) |
| `PRIVACY.md` | Recommended | Data handling disclosure (builds user trust) |

**README.md must include:**
- What the plugin does (one paragraph)
- Installation instructions (both marketplace and manual)
- Uninstallation instructions
- Usage examples
- All slash commands / skills / agents listed
- External dependencies (if any)
- License reference
- OS compatibility statement

**PRIVACY.md must include:**
- What data the plugin accesses (files, git history, network, etc.)
- What data is stored and where
- What data is sent externally (if any)
- What data persists after uninstallation
- How to delete stored data

---

### 2. Manifest Validation (plugin.json)

**Required fields:**

```json
{
  "name": "kebab-case-name",
  "displayName": "Human Readable Name",
  "version": "X.Y.Z",
  "description": "Brief explanation shown in plugin manager",
  "author": { "name": "author-name" },
  "repository": "https://github.com/...",
  "license": "SPDX-identifier",
  "keywords": ["relevant", "tags"]
}
```

**Validation rules:**
- `name` must be kebab-case (lowercase, hyphens, digits only)
- `name` must not conflict with reserved names (`claude-plugins-official`, `anthropic-marketplace`, etc.)
- `version` must be valid semver (MAJOR.MINOR.PATCH)
- `license` must be a valid SPDX identifier
- `description` should be under 120 characters
- `keywords` should have 3-6 relevant terms

**Run CLI validation:**

```bash
claude plugin validate <plugin-path>
claude plugin validate <plugin-path> --strict
```

Fix all errors. Warnings in strict mode also block marketplace acceptance.

---

### 3. Cross-OS Compatibility Audit

Check every script and hook for portability issues:

**Shell scripts:**
- [ ] Use `#!/usr/bin/env bash` shebang (not `#!/bin/bash`)
- [ ] No hardcoded absolute paths — use `${CLAUDE_PLUGIN_ROOT}` exclusively
- [ ] No `~/` paths — use `$HOME` with quotes: `"$HOME/.claude/..."`
- [ ] No GNU-only flags (e.g., `date --iso` → use `date -u +"%Y-%m-%dT%H:%M:%S.000Z"`)
- [ ] No `readlink -f` (not available on macOS) — use `cd "$(dirname "$0")" && pwd`
- [ ] All paths double-quoted (Windows usernames can contain spaces)
- [ ] Scripts marked executable (`chmod +x`)

**Hook commands:**
- [ ] Prefer exec form (`"command": "bash", "args": [...]`) over shell form
- [ ] Never invoke bare `npm`, `npx`, `python` — use full paths via `${CLAUDE_PLUGIN_ROOT}`
- [ ] If using `jq`, provide grep/python fallback (jq may not be installed)
- [ ] Wrap `${CLAUDE_PLUGIN_ROOT}` in quotes in shell form commands

**Path handling:**
- [ ] No `..` traversal in any path (blocked after marketplace install)
- [ ] No paths outside plugin root
- [ ] Use `/` separators (Windows Git Bash handles forward slashes)

**External dependencies:**
- [ ] Document ALL required external tools in README.md
- [ ] Prefer built-in tools (bash, grep, sed) over optional ones
- [ ] If requiring python3/node, state minimum version

---

### 4. Security Audit

**Critical checks:**
- [ ] No secrets, tokens, or credentials in any file
- [ ] No API keys hardcoded anywhere
- [ ] No `.env` files included
- [ ] No user-specific paths hardcoded
- [ ] Hook scripts cannot execute arbitrary user input without sanitization
- [ ] No command injection vectors (variables in unquoted command positions)
- [ ] Shell variables properly quoted: `"$VAR"` not `$VAR`
- [ ] No `eval` usage with external input
- [ ] No network calls without user knowledge (document in PRIVACY.md)
- [ ] `userConfig` fields with `sensitive: true` for any tokens/keys

**Plugin agent restrictions (verify compliance):**
- Agents must NOT use `hooks`, `mcpServers`, or `permissionMode` frontmatter
- Agents can only use: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`

**File permissions:**
- [ ] No files with excessive permissions (no `777`)
- [ ] Scripts use `755` or `+x` only

---

### 5. Token Cost Audit

Check projected token cost:

```bash
claude plugin details <plugin-name>
```

**Guidelines:**
- Always-on cost (listing text): minimize — every token costs on EVERY session
- Skill descriptions: put key use case FIRST, keep under 1536 chars combined with `when_to_use`
- SKILL.md: keep under 500 lines; move reference material to supporting files
- Agent definitions: keep system prompts concise

**If token cost is high:**
- Split large skills into a brief SKILL.md + referenced files
- Shorten descriptions without losing trigger accuracy
- Remove redundant text

---

### 6. Quality Standards

**Naming:**
- Plugin name matches `^[a-z0-9]([a-z0-9-]*[a-z0-9])?$`
- Skill names are descriptive and don't conflict with built-in commands
- No duplicate skill/command/agent names within the plugin

**Skill quality:**
- `description` field is specific enough for auto-invocation
- Trigger phrases cover common variations of user intent
- `allowed-tools` declares minimum required tools (not everything)

**Hooks quality:**
- All hooks have reasonable `timeout` values
- Hooks handle missing dependencies gracefully (exit 0, not crash)
- Stop hooks return valid JSON (`{"decision": "approve"}` or `{"decision": "block", "reason": "..."}`)

**Versioning:**
- Version in plugin.json matches CHANGELOG.md latest entry
- Git tag exists: `<plugin-name>--v<version>`

---

### 7. Pre-Submission Checklist

Before submitting to Anthropic marketplace:

```
[ ] claude plugin validate <path> passes cleanly
[ ] claude plugin validate <path> --strict passes cleanly
[ ] README.md has install + uninstall + usage + OS support
[ ] LICENSE file present with valid SPDX license
[ ] CHANGELOG.md documents current version
[ ] PRIVACY.md describes data handling
[ ] All hook scripts work on macOS, Linux, and Windows (Git Bash)
[ ] No secrets or user-specific paths in any file
[ ] Version bumped from previous release
[ ] Git tag created: plugin-name--vX.Y.Z
[ ] Repository is public
[ ] No paths traverse outside plugin root
[ ] Token cost is reasonable (check with claude plugin details)
```

---

### 8. Submission

**Community marketplace:**
- Submit at: `claude.ai/settings/plugins/submit` or `platform.claude.com/plugins/submit`
- Anthropic runs automated security scanning + manual review
- Do NOT submit via GitHub PR (auto-closed)
- After approval, plugin is pinned to a specific commit SHA
- CI auto-bumps the pin as you push new commits

**Check submission status:**
- Look for your plugin name in `anthropics/claude-plugins-community` marketplace.json

---

### 9. Final Report

After all checks pass, output:

```
Package ready: <plugin-name> v<version>
  Files: plugin.json ✓ | README ✓ | LICENSE ✓ | CHANGELOG ✓ | PRIVACY ✓
  Validation: clean (strict) ✓
  Cross-OS: macOS ✓ | Linux ✓ | Windows ✓
  Security: no issues ✓
  Token cost: <N> always-on / <N> on-invoke
  Submit at: claude.ai/settings/plugins/submit
```
