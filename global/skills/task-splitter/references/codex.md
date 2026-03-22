# Codex CLI Reference

## Non-interactive execution

```bash
# Basic non-interactive run (streams progress to stderr, result to stdout)
codex exec "Your task description"

# Short form
codex e "Your task description"

# With model
codex exec "Refactor auth module" -m gpt-4o

# Set working directory
codex exec "Add error handling to all routes" -C ./src

# Full auto (sandbox + auto-approve)
codex exec "..." --full-auto

# JSON output (machine-readable)
codex exec "..." --json

# Save final message to file
codex exec "..." -o /tmp/result.md
```

## Approval modes

Controls how autonomous Codex can be. For task-splitter, use `--full-auto` or `never`:

```bash
# Most autonomous — safe sandbox + on-request approvals
codex exec "..." --full-auto

# Fully automatic, no approval prompts
codex exec "..." --ask-for-approval never

# Conservative (requires approval for most actions)
codex exec "..." --ask-for-approval untrusted
```

## Sandbox modes

```bash
# Read-only (default — safest)
codex exec "..." -s read-only

# Can edit files in workspace
codex exec "..." -s workspace-write

# Broadest access
codex exec "..." -s danger-full-access
```

## Session management

```bash
# Continue previous session
codex resume

# Continue specific session
codex resume <session-id>

# Don't persist session to disk
codex exec "..." --ephemeral
```

## Key flags

| Flag | Description |
|---|---|
| `exec` / `e` | Non-interactive mode |
| `-m model` | Model selection |
| `-C dir` | Set working directory |
| `--full-auto` | Auto-approve + workspace-write sandbox |
| `--ask-for-approval mode` | `untrusted`, `on-request`, `never` |
| `-s mode` | Sandbox: `read-only`, `workspace-write`, `danger-full-access` |
| `--json` | JSON Lines output |
| `-o path` | Write final message to file |
| `--ephemeral` | Skip session persistence |
| `-i file` | Attach image file |

## Best for in task-splitter

- Isolated code edits that shouldn't affect other parts of the codebase
- Tasks where sandboxing is important (untrusted code, risky refactors)
- File editing with full OS-level isolation
- Tasks that benefit from session resume (multi-step work)
