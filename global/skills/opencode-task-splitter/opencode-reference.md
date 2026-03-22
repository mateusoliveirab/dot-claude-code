# OpenCode CLI Reference

Complete command reference for OpenCode CLI. For guided workflow, see [SKILL.md](./SKILL.md).

## Core Commands

### Create Custom Agent

```bash
opencode agent create
```

Prompts you to define:
- Agent name
- System prompt (how the agent should think/behave)
- Enabled tools (which tools the agent can use)

**When to use:** Only when you need specialized behavior for specific task types (e.g., security-focused testing, performance optimization).

### List Available Agents

```bash
opencode agent list
```

Shows all agents available for use. Default agent is always available.

### Run Task

```bash
opencode run "your task description here"
```

Executes task without starting the full TUI. Output streams to terminal.

**Common flags:**
- `--agent <name>` — Use specific agent (default: default)
- `--title <name>` — Label for session (appears in `opencode session list`)
- `--file <path>` — Attach file(s) to provide context
- `--format json` — Output as JSON for parsing
- `--model provider/model` — Override model (e.g., anthropic/claude-opus-4-6)

**Example:**
```bash
opencode run --title "auth-refactor" --file auth.js "Refactor auth patterns"
```

### Start Server for Parallel Execution

```bash
opencode serve --port 4096
```

Starts a server that agents can attach to. Enables true parallel execution without cold starts.

**Why use:** First parallel run is slow (cold boot). Server pre-warms agent runtime so subsequent runs attach instantly.

### Attach to Running Server

```bash
opencode run --attach http://localhost:4096 "your task"
```

Connects to server instead of starting new agent. Use in separate terminals for parallel execution.

**Example workflow:**
```bash
# Terminal 1: Start server
opencode serve --port 4096

# Terminals 2, 3, 4...
opencode run --attach http://localhost:4096 --title "task1" "..."
opencode run --attach http://localhost:4096 --title "task2" "..."
opencode run --attach http://localhost:4096 --title "task3" "..."
```

### List Sessions

```bash
opencode session list
```

Shows all completed/running sessions with results. Use to verify subtask outputs.

## Flag Reference

| Flag | Purpose | Example |
|------|---------|---------|
| `--agent <name>` | Specify agent to use | `--agent refactor-expert` |
| `--model <provider/model>` | Override LLM model | `--model anthropic/claude-opus-4-6` |
| `--file <path>` | Attach file as context | `--file src/auth.js` |
| `--files <paths>` | Attach multiple files | `--files src/*.js` |
| `--format json` | JSON output | `--format json` |
| `--title <name>` | Session identifier | `--title my-task` |
| `--port <number>` | Server port (serve only) | `--port 4096` |
| `--attach <url>` | Connect to server | `--attach http://localhost:4096` |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `OPENCODE_MODELS_URL` | Custom model configuration URL |
| `OPENCODE_ENABLE_EXA` | Enable Exa web search tools (`true`/`false`) |
| `OPENCODE_EXPERIMENTAL` | Enable all experimental features (`true`/`false`) |

## Practical Scenarios

### Scenario 1: Large Refactoring Across 3 Modules

```bash
# Start server for parallel execution
opencode serve --port 4096 &
SERVER_PID=$!

# Extract patterns from module A
opencode run --attach http://localhost:4096 \
  --title "extract-patterns-moduleA" \
  --file src/moduleA.js \
  "Extract reusable patterns and document them"

# Refactor module B using patterns from A
opencode run --attach http://localhost:4096 \
  --title "refactor-moduleB" \
  --file src/moduleB.js \
  "Refactor to use patterns documented in moduleA extraction"

# Refactor module C using patterns from A
opencode run --attach http://localhost:4096 \
  --title "refactor-moduleC" \
  --file src/moduleC.js \
  "Refactor to use patterns documented in moduleA extraction"

# View all results
opencode session list

# Cleanup
kill $SERVER_PID
```

### Scenario 2: Feature with Backend + Frontend + Tests

```bash
# Without server (sequential is okay for ~3 tasks)
opencode run --title "feature-backend" \
  "Implement user roles in database schema"

opencode run --title "feature-frontend" \
  --file src/components/UserForm.tsx \
  "Add role selector dropdown to user form"

opencode run --title "feature-integration" \
  "Connect frontend role selector to backend API"

opencode run --title "feature-tests" \
  "Write tests for role selector and backend integration"
```

### Scenario 3: Code Analysis Across 5 Modules (Parallel)

```bash
opencode serve --port 4096 &

for module in moduleA moduleB moduleC moduleD moduleE; do
  opencode run --attach http://localhost:4096 \
    --title "analyze-$module" \
    --file "src/$module.js" \
    "Identify performance bottlenecks and suggest optimizations" &
done

wait
opencode session list
```

## Best Practices

- **Server for true parallelism:** Use `opencode serve` when running 3+ subtasks simultaneously
- **Descriptive titles:** Use titles that clearly identify each subtask (e.g., `"auth-extract-patterns"` not `"task1"`)
- **File context:** Attach relevant files with `--file` so agent has necessary context
- **Review before merge:** Always review generated code before integrating results
- **Test end-to-end:** After integrating subtask results, run full system tests
- **Sequential first:** Start with sequential runs to verify decomposition works, then parallelize

