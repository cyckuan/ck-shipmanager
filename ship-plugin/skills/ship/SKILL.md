---
name: ship
description: This skill should be used when the user asks to "ship changes", "ship it", "commit and push", "send it", "ship my code", "/ship", "/ship on", "/ship off", or wants to stage, commit, and sync their work with the remote. Guides through the full git add → commit → pull --rebase → push shipping sequence.
argument-hint: "[on|off|type description]"
allowed-tools: ["Bash", "Read", "Write"]
---

# Ship Changes

Ship fast. Prioritize speed over caution. The only exception is rebase conflicts — stop and ask.

## Command Modes

- **`/ship`** or **`/ship <type> <description>`** — Execute shipping sequence now.
- **`/ship on`** — Write `{"autoship": true}` to `$CLAUDE_PROJECT_DIR/.claude/ship.local.json`. Confirm briefly.
- **`/ship off`** — Write `{"autoship": false}` to `$CLAUDE_PROJECT_DIR/.claude/ship.local.json`. Confirm briefly.

If type and description are provided (e.g. `/ship feat add login page`), use them directly as the commit message.

## Shipping Sequence

Run fast, minimal output. Do not narrate each step.

### Step 0: Housekeeping

#### TODOLIST.md

Read `TODOLIST.md` if it exists. Check off completed items with `[x]`. If work done is not listed as a TODO, add it to the `## COMPLETED` section. If the file does not exist, create it:

```markdown
# TODOLIST

## TODO

## COMPLETED
- [x] <work done>
```

#### README.md

If `README.md` exists and the shipped changes affect user-facing behavior (new features, changed commands, modified setup), update it. Otherwise skip.

### Step 1: Stage

```bash
git add -A
```

Use `git add -A`. Do not deliberate over individual files — speed over caution. Only exception: skip files that are obviously secrets (`.env`, credentials) if they appear.

### Step 2: Commit

**Format:** `type:description` — no space after colon, lowercase, imperative, under 72 chars, no period.

**Types:** `feat` | `fix` | `chore` | `docs` | `refactor` | `test` | `style` | `perf` | `ci` | `build`

Pick the obvious type. Do not agonize. Commit immediately:

```bash
git commit -m "type:description"
```

### Step 3: Pull

```bash
git pull --rebase
```

**If rebase conflict: STOP. Report to user. Do not resolve automatically.** This is the one place to be careful.

### Step 4: Push

```bash
git push
```

If rejected, pull --rebase once and retry. If no upstream, use `git push -u origin <branch>`.

## Auto-Ship Mode

When enabled via `/ship on`, a Stop hook blocks Claude from stopping if there are uncommitted changes. Ship everything automatically — no questions, no deliberation. Best-guess commit message, ship all files.

## Failure Handling

- **Commit hook fails:** Fix and retry with new commit.
- **Push rejected:** Pull --rebase, retry once.
- **Rebase conflict:** Stop and report. Wait for user.
- **Anything else:** Report briefly, do not block.

## Output Style

Be terse. After shipping, report one line:

```
Shipped: <commit-hash> <type:description> → <branch>
```

Do not recap the steps. Do not explain what was done. The user knows.
