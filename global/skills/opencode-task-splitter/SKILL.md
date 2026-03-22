---
name: opencode-task-splitter
description: Use when a task is too large for single execution, requires parallel subtasks, or needs specialized agents—multiple modules need changes, large refactoring, or independent concerns. Executes real `opencode run` CLI commands via Bash to dispatch subtasks in parallel with model routing per task type.
metadata:
  requires: opencode CLI
  execution: bash — opencode run via terminal, never internal Task tool
  script: scripts/serve.sh — starts headless server, exports $OC_URL for parallel runs
  model-routing: assign free models (glm-5-free, kimi-k2.5-free) for analysis/docs, premium for complex logic
---

# OpenCode Task Splitter

Split large, complex tasks into independent subtasks for parallel execution using OpenCode CLI agents. Enables faster delivery through parallelization, specialization, and cost-optimized model routing.

## Agent Instructions

> **IMPORTANT:** This skill requires executing real `opencode` CLI commands via the Bash tool.
> Do NOT use the internal Task tool, subagents, or any Claude Code mechanism as a substitute.
> Every subtask must be dispatched as an actual `opencode run` Bash command.

### Mandatory startup — always run this first

```bash
# This script starts the opencode server, exports $OC_URL and $OC_PORT,
# handles port conflicts automatically, and registers cleanup on exit.
source ~/.claude/skills/opencode-task-splitter/scripts/serve.sh
```

> Without sourcing `serve.sh`, `$OC_URL` will be undefined and `--attach` will fail.
> Do not skip this step or replace it with a manual `opencode serve` call.

### Then run subtasks

```bash
opencode run --attach $OC_URL --title "name" --model "opencode/glm-5-free" "prompt" &
opencode run --attach $OC_URL --title "name" --model "opencode/big-pickle" "prompt" &
wait
```

## When to Use

✅ **Use when:**
- Task spans multiple files/modules and each module can be worked independently
- Refactoring is large-scale (100+ lines, 3+ files affected)
- Adding features with multiple layers (backend + frontend + integration)
- Running parallel analysis or code review across modules
- Task naturally decomposes into non-sequential work
- Subtasks have no data dependencies (output of one isn't input to another)

❌ **Don't use for:**
- Single-file changes or simple bug fixes
- Tasks where subtasks are sequential (output of A feeds input to B)
- Complex dependencies between subtasks
- When execution must be coordinated or orchestrated
- Learning OpenCode (start with sequential `opencode run` first)

## Model Routing Strategy

Assign the right model per subtask type to optimize cost and quality:

| Subtask type | Recommended model | Rationale |
|---|---|---|
| Analysis, summarization, docs | `opencode/glm-5-free` or `opencode/kimi-k2.5-free` | Free, sufficient for reading/writing |
| Simple code generation, tests | `opencode/gpt-5-nano` | Fast, low cost |
| Complex logic, architecture | `opencode/big-pickle` or premium model | Needs deeper reasoning |
| PR review, multi-file refactor | `opencode/glm-5-free` + `--variant high` | Free with boosted effort |

Use `opencode models --refresh` to see all available models. Use `opencode stats` after a run to track actual cost per session.

## Workflow

> **Degrees of freedom:** LOW = follow exactly, MED = adapt to context, HIGH = use judgment.

- [ ] **Step 1 — Analyze decomposability** `HIGH`
  - Confirm subtasks are **independent** (no output of A feeds input of B)
  - Confirm subtasks are **module-based** (different files/areas)
  - If any dependency exists → abort split, run sequentially instead
  - _Checkpoint:_ Can you describe each subtask without referencing another's output? If not, don't split.

- [ ] **Step 2 — Assign models per subtask** `MED`
  - Map each subtask to a model using the routing table above
  - Use `--variant minimal` for speed, `--variant high` for deeper reasoning
  - Use `--thinking` flag when you need visible reasoning trace for debugging

- [ ] **Step 3 — Create specialized agents** (optional) `HIGH`
  - Skip if the default agent fits the task
  - Create a custom agent only for specific domain focus or custom system prompt
  ```bash
  opencode agent create
  # Follow prompts to define system prompt + tool configuration
  ```

- [ ] **Step 4 — Execute subtasks via Bash** `LOW`

  > Run these commands with the Bash tool. Do not substitute with Task tool or internal agents.

  **Option A: Sequential (simpler)**
  ```bash
  opencode run --title "subtask-1" --model opencode/glm-5-free "describe first subtask"
  opencode run --title "subtask-2" --model opencode/gpt-5-nano "describe second subtask"
  ```

  **Option B: True parallel (faster)** — use the helper script to manage the server
  ```bash
  # Start server (sets $OC_URL and $OC_PORT, handles port conflicts, cleanup on exit)
  source ~/.claude/skills/opencode-task-splitter/scripts/serve.sh

  # Run subtasks in parallel (append & to background each one)
  opencode run --attach $OC_URL --title "analysis" \
    --model opencode/glm-5-free --dir ./src "..." &
  opencode run --attach $OC_URL --title "codegen" \
    --model opencode/big-pickle --dir ./src "..." &
  opencode run --attach $OC_URL --title "tests" \
    --model opencode/gpt-5-nano --dir ./tests "..." &

  wait   # block until all background jobs finish
  ```

  **Option C: Network-wide parallel (multi-machine)**
  ```bash
  opencode serve --mdns   # exposes server on local network as opencode.local
  # Other machines: opencode attach opencode.local
  ```

- [ ] **Step 5 — Verify and integrate results** `MED`
  ```bash
  opencode session list                  # list all sessions
  opencode export <sessionID>            # export session as JSON for programmatic review
  opencode stats                         # check token usage and cost per session
  ```
  - Review each subtask output before merging
  - Integrate results manually (merge code, resolve conflicts)
  - _Checkpoint:_ Run tests after integration. If failures exist, fix before committing.
  - Commit only after full system test passes

## Example: Large Refactoring with Model Routing

**Task:** Refactor authentication module (auth.js, middleware.js, routes.js, tests/)

**Decomposition + model assignment:**
- Subtask 1: Extract auth patterns from auth.js → `glm-5-free` (analysis only)
- Subtask 2: Refactor middleware.js → `big-pickle` (critical code change)
- Subtask 3: Refactor routes.js → `big-pickle` (critical code change)
- Subtask 4: Write tests → `gpt-5-nano` (structured, repetitive)

```bash
opencode serve &
PORT=<port shown in output>

opencode run --attach http://localhost:$PORT \
  --title "extract-auth-patterns" --model opencode/glm-5-free \
  --file auth.js "Extract reusable patterns from auth.js, document them"

opencode run --attach http://localhost:$PORT \
  --title "refactor-middleware" --model opencode/big-pickle \
  --file middleware.js "Refactor middleware to use extracted auth patterns"

opencode run --attach http://localhost:$PORT \
  --title "refactor-routes" --model opencode/big-pickle \
  --file routes.js "Refactor routes to use extracted auth patterns"

opencode run --attach http://localhost:$PORT \
  --title "write-tests" --model opencode/gpt-5-nano \
  --file tests/ "Write tests for refactored auth module"

# After all complete:
opencode stats   # review cost breakdown
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Same premium model for all subtasks | Use model routing — free models handle analysis well |
| Creating dependent subtasks | Each subtask must be describable without referencing another's output |
| Forgetting `--dir` when attaching | Omitting `--dir` may run agents in the wrong directory |
| Not checking `opencode stats` | Track costs after each parallel run to validate routing decisions |
| Skipping integration testing | Always run full system tests before committing |
| Parallel execution on cold start | `opencode serve` must be running before any `--attach` calls |

## For Full Command Reference

See [opencode-reference.md](./opencode-reference.md) for complete flag documentation, environment variables, and additional examples.
