# Auto Memory

Claude Code persists learnings across conversations in `~/.claude/projects/<project>/memory/MEMORY.md`. Claude writes to it automatically — no setup needed.

**Key distinction:** This is local AI memory, not project documentation. It's volatile, unversioned, and personal. Important learnings should be promoted to `CLAUDE.md` or `CONTRIBUTING.md`.

## What goes in it

| Write | Skip |
|---|---|
| Non-obvious solutions | General programming knowledge |
| Mistakes and lessons | Project docs (use `CLAUDE.md`) |
| Workflow patterns | Temporary workarounds |

## Limits

- Max 200 lines (truncated after)
- Local only — never commit to git
- Per-project — not shared across repos

## Promoting learnings

If a memory proves permanent and useful for others, move it to a versioned file:

```markdown
# CLAUDE.md or CONTRIBUTING.md
Dev server is usually already running — test on localhost directly.
```

## Reset

```bash
rm ~/.claude/projects/<project>/memory/MEMORY.md
```
