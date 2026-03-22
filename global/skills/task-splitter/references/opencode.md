# OpenCode CLI Reference

OpenCode is the only CLI in task-splitter that supports **shared sessions** across parallel agents via `--attach`. Use it when subtasks need to share context or coordinate on the same codebase.

## Non-interactive execution

```bash
# Basic run
opencode run "Your task description"

# With model
opencode run -m anthropic/claude-sonnet-4-6 "..."

# With file context
opencode run -f src/auth.js "Refactor this file"

# With working directory
opencode run --dir ./src "..."

# With title (for session tracking)
opencode run --title "auth-refactor" "..."

# Continue last session
opencode run -c "..."
```

## Parallel execution (shared server)

OpenCode's `--attach` flag connects multiple agents to the same server instance, enabling shared context. This is the primary reason to choose OpenCode for coordinated multi-file work.

```bash
# Start server (sets $OC_URL, handles port conflicts, cleans up on exit)
source ~/.claude/skills/task-splitter/scripts/serve.sh

# Run subtasks in parallel — all share the same server context
opencode run --attach $OC_URL --title "analysis" \
  --model opencode/glm-5-free --dir ./src "..." &

opencode run --attach $OC_URL --title "codegen" \
  --model opencode/big-pickle --dir ./src "..." &

opencode run --attach $OC_URL --title "tests" \
  --model opencode/gpt-5-nano --dir ./tests "..." &

wait
```

> Without sourcing `serve.sh`, `$OC_URL` is undefined and `--attach` will fail.

## Model routing

OpenCode supports routing per-subtask. Use `opencode models` to see all available.

| Subtask type | Model | Rationale |
|---|---|---|
| Analysis, docs, summaries | `opencode/glm-5-free` | Free, sufficient for reading/writing |
| Simple codegen, tests | `opencode/gpt-5-nano` | Fast, low cost |
| Complex logic, architecture | `opencode/big-pickle` | Deep reasoning |
| PR review, multi-file refactor | `opencode/glm-5-free --variant high` | Free + boosted effort |

```bash
# Refresh model list
opencode models --refresh

# Track cost per session
opencode stats
```

## Variants and thinking

```bash
# Boosted effort (more thorough)
opencode run --variant high "..."

# Minimal (faster)
opencode run --variant minimal "..."

# Show reasoning trace (for debugging)
opencode run --thinking "..."
```

## Session inspection

```bash
opencode session list                  # list all sessions
opencode export <sessionID>            # export as JSON
opencode stats                         # token usage and cost
opencode stats --days 7 --models 5    # filtered stats
```

## Key flags

| Flag | Description |
|---|---|
| `-m provider/model` | Model selection |
| `--attach url` | Connect to running server (enables shared context) |
| `--title name` | Session title |
| `--dir path` | Working directory |
| `-f path` | Attach file |
| `-c` | Continue last session |
| `--variant level` | `minimal`, `high` effort |
| `--thinking` | Show reasoning trace |
| `--format json` | JSON output |

## Best for in task-splitter

- Multi-file refactors where agents need shared context
- Tasks requiring premium Claude reasoning
- When you need cost tracking across subtasks (`opencode stats`)
- Coordinated work where session sharing matters
