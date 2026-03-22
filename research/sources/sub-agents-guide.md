# Sub-Agents — Create Custom Subagents

> Source: https://code.claude.com/docs/en/sub-agents
> Captured: 2026-03-22

> See also: `sub-agents.md` for the earlier reference. This is the comprehensive guide from code.claude.com.

## Overview

Subagents are specialized AI assistants that handle specific types of tasks. Each runs in its own context window with:
- Custom system prompt
- Specific tool access
- Independent permissions

When Claude encounters a task matching a subagent's description, it delegates to that subagent, which works independently and returns results.

**Benefits:**
- **Preserve context** — keep exploration and implementation out of main conversation
- **Enforce constraints** — limit which tools a subagent can use
- **Reuse configurations** across projects
- **Specialize behavior** with focused system prompts
- **Control costs** by routing tasks to faster, cheaper models (Haiku)

## Built-in Subagents

| Agent | Model | Tools | Purpose |
| ----- | ----- | ----- | ------- |
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | — | Terminal commands in separate context |
| **statusline-setup** | Sonnet | — | When you run `/statusline` |
| **Claude Code Guide** | Haiku | — | Questions about Claude Code features |

## Create a Subagent

### Via `/agents` Command (Recommended)

```text
/agents
```

Guided interface for:
- View all available subagents (built-in, user, project, plugin)
- Create new subagents
- Edit existing configuration
- Delete custom subagents
- See which are active when duplicates exist

### List from CLI

```bash
claude agents
```

### Via Markdown Files

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

## Subagent Scope

| Location | Scope | Priority | How to create |
| -------- | ----- | -------- | ------------- |
| `--agents` CLI flag | Current session | 1 (highest) | JSON when launching |
| `.claude/agents/` | Current project | 2 | Interactive or manual |
| `~/.claude/agents/` | All your projects | 3 | Interactive or manual |
| Plugin's `agents/` dir | Where plugin enabled | 4 (lowest) | Installed with plugins |

When multiple subagents share the same name, higher-priority location wins.

### CLI-Defined Subagents (per session)

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

## Frontmatter Fields

| Field | Required | Description |
| ----- | -------- | ----------- |
| `name` | Yes | Unique identifier (lowercase + hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited/specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Max agentic turns before subagent stops |
| `skills` | No | Skills to inject into subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | `worktree` to run in isolated git worktree |

## Tool Control

### Allowlist (`tools`)

```yaml
tools: Read, Grep, Glob, Bash
```

### Denylist (`disallowedTools`)

```yaml
disallowedTools: Write, Edit
```

If both set: `disallowedTools` applied first, then `tools` resolved against remaining pool.

### Restrict Spawnable Subagents

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Only `worker` and `researcher` subagents can be spawned. `Agent` (no parens) = allow spawning any subagent.

> Note: In v2.1.63, the Task tool was renamed to Agent. `Task(...)` still works as alias.

## Models

```yaml
model: sonnet     # alias
model: opus       # alias
model: haiku      # alias
model: claude-opus-4-6  # full model ID
model: inherit    # same as main conversation (default)
```

## Permission Modes

| Mode | Behavior |
| ---- | -------- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts |
| `plan` | Plan mode (read-only exploration) |

> ⚠️ `bypassPermissions` with caution. Writes to `.git`, `.claude`, `.vscode`, `.idea` still prompt (except `.claude/commands`, `.claude/agents`, `.claude/skills`).
> If parent uses `bypassPermissions`, takes precedence and cannot be overridden.

## Scope MCP Servers to a Subagent

```yaml
mcpServers:
  # Inline definition: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses already-configured server
  - github
```

## Persistent Memory

```yaml
memory: user      # ~/.claude/agent-memory/<name>/
memory: project   # .claude/agent-memory/<name>/
memory: local     # .claude/agent-memory-local/<name>/
```

When enabled:
- System prompt includes instructions for reading/writing memory directory
- First 200 lines of `MEMORY.md` included in system prompt
- Read, Write, Edit tools automatically enabled

**Tips:**
- `project` is recommended default (shareable via version control)
- Ask subagent to consult memory before starting work
- Ask subagent to update memory after completing a task
- Include memory instructions in the subagent's markdown body

## Skills in Subagents

```yaml
skills:
  - api-conventions
  - error-handling-patterns
```

Full skill content injected at startup. Subagents don't inherit skills from parent — list them explicitly.

## Hooks in Subagents

### In Subagent Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh $TOOL_INPUT"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

`Stop` hooks in frontmatter are automatically converted to `SubagentStop` events.

### Project-Level Hooks for Subagent Events (settings.json)

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [{ "type": "command", "command": "./scripts/setup-db-connection.sh" }]
      }
    ]
  }
}
```

## Disable Specific Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

```bash
claude --disallowedTools "Agent(Explore)"
```

## Invoke Subagents

### Natural Language
```text
Use the test-runner subagent to fix failing tests
```

### @-Mention (guarantees delegation)
```text
@"code-reviewer (agent)" look at the auth changes
```

Plugin subagents: `@agent-<plugin-name>:<agent-name>`

### Session-Wide (`--agent` flag)

```bash
claude --agent code-reviewer
```

The subagent's system prompt replaces the default Claude Code system prompt entirely. CLAUDE.md files and project memory still load.

```json
// Make default for a project in .claude/settings.json
{ "agent": "code-reviewer" }
```

## Foreground vs Background

- **Foreground** (default): blocks main conversation; permission prompts passed through
- **Background**: runs concurrently; requires upfront permission approval; auto-denies anything not pre-approved

```text
run this in the background
```

```
Ctrl+B  — background a running task
```

Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

## Resume Subagents

```text
Use the code-reviewer subagent to review the authentication module
[Agent completes]

Continue that code review and now analyze the authorization logic
```

Resumed subagents retain full conversation history. Claude uses `SendMessage` with the agent's ID.

Transcripts stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

## Auto-Compaction

Subagents support automatic compaction (same logic as main conversation). Default trigger: ~95% capacity.
Override: `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`

## Common Patterns

### Isolate High-Volume Operations
```text
Use a subagent to run the test suite and report only the failing tests with their error messages
```

### Parallel Research
```text
Research the authentication, database, and API modules in parallel using separate subagents
```

### Chain Subagents
```text
Use the code-reviewer subagent to find performance issues, then use the optimizer subagent to fix them
```

## Example Subagents

### Code Reviewer (Read-Only)

```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code is clear and readable
- No duplicated code, proper error handling
- No exposed secrets or API keys
- Good test coverage, performance considered

Provide feedback organized by:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider improving)
```

### Debugger

```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use proactively when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
---

You are an expert debugger specializing in root cause analysis.

When invoked:
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Implement minimal fix
5. Verify solution works
```

### Data Scientist

```markdown
---
name: data-scientist
description: Data analysis expert for SQL queries, BigQuery operations, and data insights.
tools: Bash, Read, Write
model: sonnet
---

You are a data scientist specializing in SQL and BigQuery analysis.
```

### DB Query Validator (with hook)

```markdown
---
name: db-reader
description: Execute read-only database queries.
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

Validation script blocks `INSERT`, `UPDATE`, `DELETE`, `DROP`, etc. with exit code 2.

## Plugin Subagents

Plugin subagents appear in `/agents` alongside custom ones.

> ⚠️ Plugin subagents do NOT support `hooks`, `mcpServers`, or `permissionMode` in frontmatter (ignored for security). Copy agent file to `.claude/agents/` or `~/.claude/agents/` if you need these fields.

## Use Subagents vs Main Conversation vs Skills

| Use case | Tool |
| -------- | ---- |
| Task produces verbose output | Subagent |
| Enforce tool restrictions | Subagent |
| Self-contained work returning a summary | Subagent |
| Frequent back-and-forth / iterative refinement | Main conversation |
| Multiple phases sharing significant context | Main conversation |
| Quick, targeted change | Main conversation |
| Reusable prompts/workflows in main context | Skills |
| Quick question already in context (no tool access needed) | `/btw` |

> Subagents cannot spawn other subagents. For nested delegation, use Skills or chain subagents from main conversation.
