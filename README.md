# ck-shipmanager

Accelerate packaging and deployment of Claude Code plugins.

## What It Does

Ship Manager provides three capabilities for plugin development workflows:

| Command | Purpose |
|---------|---------|
| `/ship` | Stage, commit, pull --rebase, push — fast |
| `/package` | Audit and prepare a plugin for marketplace submission |
| `/install-local` | Install the current plugin repo locally (physical copies, not symlinks) |

Plus the `swd` shorthand — append it to any prompt to auto-ship when the task completes.

## Quick Start

```bash
# Install the ship plugin
./install.sh

# Restart Claude Code, then:
/ship              # ship current changes
/package           # audit + prepare for release
/install-local     # deploy plugin locally for testing
```

## Plugin Structure

```
ship-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── package.md
│   └── install-local.md
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── auto-ship-check.sh
│   └── swd-detect.sh
└── skills/
    ├── ship/SKILL.md
    ├── install/SKILL.md
    └── package/SKILL.md
```

## License

[Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/)
