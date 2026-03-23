---
name: careful
description: Activate careful mode — behavioral guardrails against dangerous commands (rm -rf, DROP TABLE, force-push, kubectl delete). Use when working in production, sensitive environments, or when the user says "be careful", "careful mode", or "/careful".
---

# Careful Mode

When activated, you MUST refuse to execute any command matching the blocked patterns below. This is behavioral enforcement — you check each Bash command against this list before executing.

## Blocked Patterns

| Pattern | Reason |
|---------|--------|
| `rm -rf` | Recursive force delete |
| `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` | Destructive SQL |
| `git push --force`, `git push -f` | History rewrite |
| `kubectl delete` | Cluster resource deletion |
| `docker system prune` | Container/image cleanup |
| `terraform destroy` | Infrastructure teardown |

## Workflow

1. **Announce** — "Careful mode activated. I will refuse destructive commands for this session."
2. **Enforce** — before every Bash tool call, check the command against blocked patterns. If matched, refuse with explanation
3. **Operate normally** — all non-destructive commands work as usual
4. **User override** — if the user explicitly says "override careful mode for this command", allow with a warning

## Gotchas

- This is behavioral, not a system hook — relies on the model following instructions
- Pattern matching is substring-based. `rm -rf` also catches `sudo rm -rf`
- Cannot catch commands inside scripts that internally run destructive operations
- For permanent blocks, use `deny` rules in `settings.json` instead
- Session-scoped only — does NOT persist across sessions
