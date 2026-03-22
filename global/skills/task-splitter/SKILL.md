---
name: task-splitter
description: >-
  Split large coding tasks into parallel subtasks dispatched to multiple AI CLI
  tools — opencode, gemini, codex, and ollama cloud models. Use when a task
  spans multiple files/modules, needs large-scale refactoring, parallel
  analysis, or cost-optimized model routing across providers. Triggers on:
  parallelize this, split into agents, run in parallel, use multiple models,
  dispatch subtasks, large multi-file refactoring requests, or any task that
  decomposes into independent workstreams across different AI tools.
---

# Task Splitter

Decompose large tasks into independent subtasks and dispatch them in parallel across AI CLI tools: **opencode**, **gemini**, **codex**, and **ollama cloud**. Faster delivery through parallelization, specialization, and cost-optimized routing.

## When to Use

✅ Good fit:
- Task spans multiple files/modules that can each be worked independently
- Large-scale refactoring (100+ lines, 3+ files)
- Parallel analysis or code review across modules
- You want to route different task types to cheaper/faster models
- Each subtask is fully self-contained — output of A is not needed by B

❌ Skip it:
- Single-file changes or simple bug fixes
- Subtasks are sequential (output of A feeds B)
- Task is small enough for one agent in one shot

> **Independence check:** Can I describe each subtask without referencing another's output? If not — run sequentially.

## Workflow

- [ ] **Step 1 — Detect available CLIs** `LOW`
  ```bash
  for cli in gemini codex ollama opencode; do
    command -v $cli &>/dev/null && echo "$cli ✓" || echo "$cli ✗ (not found)"
  done
  ```
  Adapt routing to what's installed. If a CLI is missing, fall back to the next best option.

- [ ] **Step 2 — Decompose the task** `HIGH`
  Break work into independent subtasks mapped to areas of the codebase. One subtask per agent.
  _Checkpoint:_ Can you describe each subtask without referencing another's output? If not — don't split.

- [ ] **Step 3 — Route each subtask to the right CLI** `MED`

  | Task type | CLI | Why | Key flags |
  |---|---|---|---|
  | Large codebase analysis, long-context review | `gemini` | 1M token context, native `@dir` file references | `-m gemini-2.5-flash --output-format json` |
  | Sandboxed autonomous code edits | `codex exec --full-auto` | OS-level sandbox, safe workspace isolation | `-s workspace-write -C <dir>` |
  | Docs, summaries, tests (cost-sensitive) | `ollama run model:cloud` | Open-source cloud models, fraction of cost | `--nowordwrap`, requires `ollama signin` |
  | Coordinated multi-file refactor | `opencode run --attach` | Only CLI with shared session across parallel agents | requires `source serve.sh` first |

  For full flag reference per CLI, see: [references/gemini.md](references/gemini.md) · [references/codex.md](references/codex.md) · [references/ollama.md](references/ollama.md) · [references/opencode.md](references/opencode.md)

- [ ] **Step 4 — Execute in parallel** `LOW`

  Track PIDs to catch failures (credits can run out mid-run):

  ```bash
  pids=()

  # Long-context analysis → Gemini
  gemini -p "Analyze @src/auth/ for security issues" \
    -m gemini-2.5-flash --output-format json > /tmp/analysis.json 2>/tmp/gemini-err.log &
  pids+=($!)

  # Sandboxed code edits → Codex
  codex exec "Refactor src/middleware.js" --full-auto -C ./src &
  pids+=($!)

  # Docs/tests (cheap) → Ollama cloud
  ollama run glm-4.6:cloud "Write unit tests for src/auth.js" \
    --nowordwrap > /tmp/tests.js 2>/tmp/ollama-err.log &
  pids+=($!)

  # Coordinated refactor → OpenCode (shared session)
  source ~/.claude/skills/task-splitter/scripts/serve.sh
  opencode run --attach $OC_URL --title "routes" --model opencode/big-pickle "Refactor src/routes.js" &
  pids+=($!)

  # Wait and report failures
  failed=()
  for pid in "${pids[@]}"; do
    wait "$pid" || failed+=($pid)
  done
  [[ ${#failed[@]} -eq 0 ]] && echo "All done." || echo "Failed PIDs: ${failed[*]} — check *-err.log files"
  ```

  **Patterns without OpenCode:**
  ```bash
  pids=()
  gemini -p "..." -m gemini-2.5-flash --output-format json > /tmp/out.json & pids+=($!)
  codex exec "..." --full-auto & pids+=($!)
  ollama run qwen3-coder:cloud "..." & pids+=($!)
  for pid in "${pids[@]}"; do wait "$pid" || echo "Job $pid failed"; done
  ```

  **Error signals when credits run out:**
  | CLI | Signal | Recovery |
  |---|---|---|
  | `ollama` cloud | Non-zero exit + auth error in stderr | `ollama signin` to refresh |
  | `gemini` | Exit code 1 + API error in output | Check quota at Google AI Studio |
  | `codex` | Non-zero exit + JSON error field | Check OpenAI billing |
  | `opencode` | Non-zero exit or session error | `opencode auth list` |

- [ ] **Step 5 — Verify and integrate** `MED`
  - Review each subtask output before applying
  - Resolve conflicts between independently-made changes
  - Run the full test suite
  - _Checkpoint:_ All tests pass before committing

## Common mistakes

| Mistake | Fix |
|---|---|
| Subtasks that depend on each other | Run sequentially or restructure to remove the dependency |
| Using premium model for docs/tests | Route to `ollama run model:cloud` — equivalent for structured tasks |
| Forgetting working directory flag | Set `-C <dir>` (codex), `--dir <path>` (opencode), `--include-directories` (gemini) |
| Forgetting `serve.sh` for opencode parallel | `--attach` fails without a running opencode server |
| Using Ollama local for complex logic | Use `:cloud` tags — local small models are weak for architecture tasks |
| Forgetting `ollama signin` | Cloud models require authentication — run `ollama signin` first |
| No PID tracking | Without `pids+=($!)` + `wait "$pid"`, credit failures are silent |
