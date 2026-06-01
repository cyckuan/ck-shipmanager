# ship-plugin

Fast, no-nonsense code shipping for Claude Code. Stage, commit, sync, push — done.

## What It Does

```
git add -A → git commit -m "type:description" → git pull --rebase → git push
```

Plus automatic housekeeping:
- **TODOLIST.md** — checks off completed items, adds shipped work to COMPLETED section, creates the file if missing
- **README.md** — updates only if shipped changes affect user-facing behavior

## Commands

| Command | Effect |
|---------|--------|
| `/ship` | Ship now |
| `/ship feat add auth` | Ship with explicit message |
| `/ship on` | Auto-ship at end of every response |
| `/ship off` | Disable auto-ship |

Also triggers on: "ship it", "ship changes", "send it", "commit and push".

## Design Philosophy

**Speed over caution.** The only time shipping stops to ask is on a rebase conflict. Everything else ships fast with minimal output.

Output after shipping is one line:
```
Shipped: a1b2c3d feat:add auth flow → main
```

## Commit Types

`feat` | `fix` | `chore` | `docs` | `refactor` | `test` | `style` | `perf` | `ci` | `build`

## Installation

```bash
./install.sh
```

Copies plugin files to `~/.claude/plugins/local/ship/`, registers in `installed_plugins.json`, and enables in `settings.json`.

Restart Claude Code after installing.

## Uninstallation

```bash
./uninstall.sh
```

Removes plugin files, deregisters from `installed_plugins.json`, and disables in `settings.json`.

**Optional cleanup:** `rm /your/project/.claude/ship.local.json`

## Structure

```
ship-plugin/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── LICENSE
├── hooks/
│   └── hooks.json
├── scripts/
│   └── auto-ship-check.sh
└── skills/
    └── ship/
        └── SKILL.md
```

## License

[Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/)

See [LICENSE](LICENSE) for full text.
