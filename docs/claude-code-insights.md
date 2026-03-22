# Claude Code Insights

A progressive guide synthesizing lessons from the Anthropic team and community on how to get the most out of Claude Code — from mental models to advanced operational patterns.

---

## 1. Lessons from Building Claude Code: How Claude Code Thinks

Before configuring anything, you need a mental model of what Claude Code actually is. Claude is not a chatbot with memory — it's an **agent that acts through tool calls** and perceives the world exclusively through its **context window**.

Every turn, Claude receives the full context (system prompt, instructions, conversation history) and produces a response that may include tool calls (read a file, run a bash command, write code). It then receives the tool results and continues. That's the entire loop.

This has real implications:

- **Every token has cost and latency.** The bigger the context, the slower and more expensive each turn. Design everything around this.
- **Claude doesn't "remember" between sessions by default.** What persists across sessions is what you explicitly put in `CLAUDE.md`, or what the auto-memory system saves automatically.
- **Context rot is real.** When the system prompt gets too large or filled with generic information, instruction adherence drops. Claude doesn't "ignore" instructions — it just has less signal-to-noise ratio. Keep context lean and specific.
- **Claude builds its own context when given the right tools.** Early versions of Claude Code used a RAG vector database to inject context. Over time, giving Claude a `Grep` tool proved better — Claude finds what it needs, on its own, when it needs it. As models get smarter, they become increasingly good at self-directed context building.
- **Tools shape what's possible.** The analogy: imagine solving a hard math problem. Paper lets you think, a calculator helps with computation, a computer lets you write and run code. You want to give Claude tools shaped to its own abilities — not too few (limiting), not too many (noisy).

> "You want to give the agent tools that are shaped to its own abilities. But how do you know what those abilities are? You pay attention, read its outputs, experiment. You learn to see like an agent."

**Progressive disclosure** is the key technique that emerges from this: instead of loading everything upfront, let Claude discover context incrementally. Skills reference other files. Agents load on demand. Tools are stubbed and deferred. The context stays lean; the capability stays deep.

> **Sources:** [Lessons from Building Claude Code: Seeing like an Agent](https://x.com/trq212/status/2027463795355095314) · [how-claude-code-works.md](../research/sources/how-claude-code-works.md)

---

## 2. Lessons from Building Claude Code: Your Control Center

The `.claude/` folder is the control center for how Claude behaves in your project. Most users treat it like a black box. That's a missed opportunity.

There are actually **two** `.claude/` directories:

- **Project-level** `.claude/` — team config, committed to git. Shared by everyone.
- **Global** `~/.claude/` — your personal preferences and machine-local state.

### CLAUDE.md — The Highest-Leverage File

When a session starts, the first thing Claude reads is `CLAUDE.md`. It loads straight into the system prompt and stays in context for the entire conversation.

**Write:**
- Build, test, and lint commands
- Key architectural decisions ("we use a monorepo with Turborepo")
- Non-obvious gotchas ("TypeScript strict mode is on, unused variables are errors")
- Import conventions, naming patterns, error handling styles

**Don't write:**
- Anything that belongs in a linter config
- Full docs you can link to
- Long explanatory paragraphs

> Keep `CLAUDE.md` under 200 lines. Files longer than that eat too much context and Claude's instruction adherence drops.

You can have multiple `CLAUDE.md` files: one at the project root, one in `~/.claude/` for global preferences, and one in subdirectories for folder-specific rules. Claude reads and combines all of them. For enterprise, a managed policy file at the OS level (`/etc/claude-code/CLAUDE.md` on Linux) applies to all users on the machine and cannot be excluded.

Use `CLAUDE.local.md` for personal overrides that shouldn't be committed.

### Importing Files with @

`CLAUDE.md` can import other files using `@path/to/file` syntax. Imported files are expanded into context at launch. Both relative and absolute paths work. Imports can chain recursively (max 5 hops). Practical uses:

```markdown
See @README for project overview and @package.json for available npm commands.

# Workflows
- git workflow: @docs/git-instructions.md

# Individual Preferences
- @~/.claude/my-personal-instructions.md
```

This lets you keep `CLAUDE.md` short while referencing detailed docs on demand — and lets engineers keep personal preferences outside the repo.

### The rules/ Folder — Modular Instructions That Scale

As `CLAUDE.md` grows, split instructions into `.claude/rules/`. Each `.md` file is loaded automatically. You can scope rules to specific paths using frontmatter:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Rules
- All handlers return { data, error }
- Use zod for request body validation
```

Rules without `paths` load every session. Rules with `paths` only load when Claude works in matching files. The `.claude/rules/` directory supports symlinks, so you can share a central rules library across multiple repos.

### commands/ — Custom Slash Commands

Every `.md` file in `.claude/commands/` becomes a slash command. `review.md` → `/project:review`. Use the `!` backtick syntax to inject shell output, and `$ARGUMENTS` to accept parameters:

```markdown
!`git diff main...HEAD`
Review these changes for issues, then fix issue #$ARGUMENTS.
```

Project commands (`/project:name`) are committed. Personal commands in `~/.claude/commands/` show up as `/user:name` everywhere.

### settings.json — Permissions

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)", "Read", "Write", "Edit"],
    "deny": ["Bash(rm -rf *)", "Read(./.env)"]
  }
}
```

- `allow` — runs without confirmation
- `deny` — blocked entirely
- Neither — Claude asks first

Use `settings.local.json` for personal permission overrides (auto-gitignored).

### MCP — Extending Claude's Action Space with External Tools

MCP (Model Context Protocol) is how you connect Claude to external systems — databases, APIs, ticket trackers, monitoring tools, browsers. Unlike skills (which teach Claude how to work with your codebase), MCPs give Claude new tools it can actively call.

Configure MCPs in `.mcp.json` and commit it so the whole team benefits:

```json
{
  "mcpServers": {
    "slack": { "command": "npx", "args": ["@anthropic/mcp-server-slack"] },
    "supabase": { "command": "npx", "args": ["@supabase/mcp-server-supabase"] }
  }
}
```

**MCP vs Skills:**
- Use **MCP** when you need real-time access to an external system (Slack, GitHub, a database, a browser)
- Use **Skills** when you want to encode knowledge, patterns, or workflows Claude should follow

> One central team should configure MCP servers and commit `.mcp.json` to the codebase so all users benefit automatically.

### Memory — Two Systems Working Together

Claude Code has two complementary memory systems, both loaded at the start of every conversation:

| | CLAUDE.md | Auto Memory |
|---|---|---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per git working tree |
| **Loaded** | Full content, every session | First 200 lines of `MEMORY.md` index |
| **Use for** | Standards, workflows, architecture | Build commands, debugging insights, preferences Claude discovers |

**Auto memory** lets Claude accumulate knowledge across sessions without you writing anything. Claude saves notes for itself: build commands it discovers, architectural patterns, debugging insights, preferences you've expressed. It decides what's worth saving based on whether it would be useful in a future conversation.

Storage: `~/.claude/projects/<project>/memory/MEMORY.md` (index) + topic files (`debugging.md`, `api-conventions.md`, etc.). Topic files are loaded on demand, not at startup.

Key commands:
- `/memory` — browse all loaded CLAUDE.md and rules files, toggle auto memory, open memory folder
- Ask Claude "remember that we always use pnpm" → it saves to auto memory
- Ask Claude "add this to CLAUDE.md" → it writes to the instruction file instead

> Auto memory survives compaction. `CLAUDE.md` also fully survives compaction — Claude re-reads it from disk after `/compact`.

> **Sources:** [Anatomy of the .claude/ Folder](https://x.com/akshay_pachaar/status/2035341800739877091) · [settings.md](../research/sources/settings.md) · [memory.md](../research/sources/memory.md)

---

## 3. Lessons from Building Claude Code: Hooks — Automating Claude's Behavior

Hooks are one of the most powerful and underused extension points in Claude Code. They are user-defined shell commands, HTTP endpoints, or LLM prompts that **execute automatically at specific points in Claude's lifecycle** — giving you programmatic control over what Claude can do, when, and how.

Hooks fire inside the agentic loop. They can inspect what's about to happen, block it, modify it, or react to it. Unlike permissions (which are static allow/deny rules), hooks are dynamic — they can apply custom logic, check context, log events, or call external systems.

### Key Hook Events

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | — |
| `UserPromptSubmit` | Before Claude processes your prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PostToolUse` | After a tool call succeeds | — |
| `PostToolUseFailure` | After a tool call fails | — |
| `Stop` | When Claude finishes responding | Yes |
| `StopFailure` | When the turn ends due to an API error | — |
| `SubagentStart` / `SubagentStop` | When a subagent is spawned/finishes | — |
| `TeammateIdle` / `TaskCompleted` | Agent team lifecycle events | Yes |
| `PreCompact` / `PostCompact` | Before/after context compaction | — |
| `Notification` | When Claude sends a notification | — |
| `InstructionsLoaded` | When a CLAUDE.md or rules file loads | — |
| `ConfigChange` | When a config file changes mid-session | — |
| `WorktreeCreate` / `WorktreeRemove` | When a git worktree is created/removed | — |
| `Elicitation` / `ElicitationResult` | When an MCP server requests user input | — |
| `SessionEnd` | When the session terminates | — |

### Configuration

Hooks are configured in `settings.json` under a `hooks` key:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/block-destructive.sh" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/notify.sh" }
        ]
      }
    ]
  }
}
```

The hook script receives JSON on stdin with full context about the event (tool name, inputs, outputs, session info). It exits 0 (allow), exits 2 (block with message), or returns JSON with a `permissionDecision`.

**Exit codes:**

| Code | Behavior |
|---|---|
| 0 | Allow. For `UserPromptSubmit`/`SessionStart`: stdout added to Claude's context |
| 2 | Block. Stderr sent to Claude as feedback |
| Other | Allow. Stderr logged but not shown |

### Four Hook Types

Beyond `command`, there are three more types that unlock judgment-based automation:

**`type: "prompt"` — LLM-based decisions:**
A lightweight model (Haiku by default) reads the event and returns `{"ok": true}` or `{"ok": false, "reason": "..."}`. No shell, no scripts — the model decides.

```json
{ "type": "prompt", "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains\"}." }
```

**`type: "agent"` — multi-turn verification with tool access:**
Spawns a subagent that can read files and run commands before deciding. Use when you need to inspect actual state, not just the event payload.

```json
{ "type": "agent", "prompt": "Verify all unit tests pass. Run the test suite and check results.", "timeout": 120 }
```

**`type: "http"` — POST to an external endpoint:**
Sends event data to a URL. Response body controls the decision (HTTP status alone can't block). Supports `$VAR` interpolation in headers via `allowedEnvVars`.

```json
{ "type": "http", "url": "http://localhost:8080/hooks/tool-use", "headers": { "Authorization": "Bearer $MY_TOKEN" }, "allowedEnvVars": ["MY_TOKEN"] }
```

### What to Build With Hooks

**Safety guardrails:**
- Block `rm -rf`, `DROP TABLE`, force-push, `kubectl delete` via `PreToolUse` on Bash
- Deny reads to `.env` or secrets directories
- Use `type: "agent"` on `Stop` to verify tests pass before declaring done

**Observability:**
- Log every tool call to a file or analytics system
- Measure skill usage via `PreToolUse` — track which skills trigger and how often
- Send a desktop notification via `Stop` when Claude finishes a long task
- Audit config changes with `ConfigChange` → append to a log file

**Workflow automation:**
- Run `prettier` automatically after every file edit (`PostToolUse` on Write/Edit)
- Post a summary to Slack when a task completes
- Trigger CI/CD pipelines on `SessionEnd`
- Re-inject sprint context after compaction: `SessionStart` with `matcher: "compact"`

**Context injection:**
- Use `SessionStart` to set up environment variables or run initialization scripts
- Use `InstructionsLoaded` to log exactly which instruction files were loaded (useful for debugging path-scoped rules)

### Hook Scope

| Location | Scope |
|---|---|
| `~/.claude/settings.json` | All projects (local machine) |
| `.claude/settings.json` | Single project (commit to repo) |
| `.claude/settings.local.json` | Single project (gitignored) |
| Skill or subagent frontmatter | Only while that component is active |
| Plugin `hooks/hooks.json` | When plugin is enabled |

### Hooks in Skills (On-Demand)

Skills can register hooks that activate **only for the duration of that session**. This is a powerful pattern for opinionated workflows you don't want running all the time:

- `/careful` — activates a `PreToolUse` hook that blocks destructive commands during a risky session
- `/freeze` — blocks any Edit/Write outside a specific directory (useful when debugging: "add logs but don't touch anything else")

Hooks can also run **asynchronously** (fire-and-forget), so they don't block Claude's loop — useful for logging, notifications, and CI triggers.

**Gotcha — infinite loops on `Stop` hooks:** A `Stop` hook that feeds back to Claude can trigger another `Stop`, looping forever. Guard against it:

```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then exit 0; fi
# ... rest of hook
```

**Gotcha — `PermissionRequest` hooks don't fire in `-p` mode.** Use `PreToolUse` instead for scripted/CI environments.

> **Sources:** [hooks.md](../research/sources/hooks.md) · [hooks-guide.md](../research/sources/hooks-guide.md)

---

## 4. Lessons from Building Claude Code: Skills, Commands & Agents

Once you understand the control center and hooks, you can extend Claude with reusable workflows. There are three extension points — and knowing when to use each one matters.

| | Commands | Skills | Agents |
|---|---|---|---|
| **Trigger** | You type `/command` | Claude decides automatically | Claude spawns on demand |
| **Format** | Single `.md` file | Folder with `SKILL.md` + assets | Single `.md` with persona |
| **Context** | Main session | Main session | Isolated context window |
| **Best for** | Repeatable manual workflows | Domain knowledge + automation | Complex isolated tasks |

### Skills — Not Just Markdown Files

A common misconception: skills are "just markdown files." They're not. Skills are **folders** that can include scripts, data files, templates, references, and even dynamic hooks — all of which Claude can discover and use.

The `description` field in the frontmatter is not a summary. It's a **trigger condition** — what Claude scans at session start to decide "is there a skill for this request?"

**9 categories of skills worth building:**

1. **Library & API Reference** — how to correctly use an internal lib, CLI, or SDK. Include gotchas.
2. **Product Verification** — test/verify code with playwright, tmux, etc. Verification skills are high-ROI; an engineer spending a week on them pays dividends every day.
3. **Data Fetching & Analysis** — connect to your data stack with credentials, dashboard IDs, query patterns.
4. **Business Process Automation** — standup posts, ticket creation, weekly recaps. Save results to logs for consistency.
5. **Code Scaffolding** — boilerplate generators with natural language requirements that linters can't enforce.
6. **Code Quality & Review** — style enforcement, adversarial review subagents, testing practices.
7. **CI/CD & Deployment** — babysit PRs, deploy pipelines, cherry-pick workflows.
8. **Runbooks** — symptom → investigation → structured report. Map alerts to tools to findings.
9. **Infrastructure Operations** — routine maintenance with guardrails for destructive actions.

**Tips for writing great skills:**

- **Don't state the obvious.** Focus on what pushes Claude out of its default behavior.
- **Build a Gotchas section.** This is the highest-signal content. Update it as Claude hits new edge cases.
- **Use progressive disclosure.** Point to `references/api.md`, `assets/template.md`. Tell Claude what files exist; it reads them when needed.
- **The description is for the model, not for humans.** Write it as a trigger condition.
- **On-demand hooks.** Skills can register hooks that activate only during that session.
- **Store persistent data in `${CLAUDE_PLUGIN_DATA}`**, not in the skill folder itself (which may be wiped on upgrade).

### Agents — Isolated Context Windows

Agents are specialized subagent personas. When Claude spawns an agent, it runs in its own isolated context window, does its work, compresses findings, and reports back. Your main session doesn't get cluttered.

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after code changes.
model: sonnet
tools: Read, Grep, Glob
permissionMode: plan
---
You are a senior code reviewer focused on correctness and maintainability.
```

**Frontmatter fields (beyond `name`, `description`, `model`, `tools`):**

| Field | Description |
|---|---|
| `disallowedTools` | Tools to deny (blocklist applied before allowlist) |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | Max agentic turns before subagent stops |
| `skills` | Skills to inject at startup (not inherited from parent) |
| `mcpServers` | MCP servers scoped to this subagent only |
| `hooks` | Lifecycle hooks scoped to this subagent |
| `memory` | Persistent memory: `user`, `project`, or `local` |
| `background` | `true` to always run as a background task |
| `effort` | `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | `worktree` to run in an isolated git worktree |

**Per-subagent memory** is one of the most underused features. Setting `memory: project` gives the subagent a persistent `MEMORY.md` at `.claude/agent-memory/<name>/` — it accumulates knowledge across invocations, much like the main session's auto memory.

**Scope priority** (when agents share the same name, highest wins):
`--agents` CLI flag → `.claude/agents/` → `~/.claude/agents/` → plugin's `agents/` dir

**Invoking subagents:**
- Natural language: `"Use the test-runner subagent to fix failing tests"`
- `@"agent-name (agent)"` — guarantees delegation (no ambiguity)
- `--agent code-reviewer` flag — makes that subagent's system prompt the session default

**Foreground vs. background:**
- **Foreground** (default): blocks main conversation; permission prompts pass through
- **Background**: runs concurrently; auto-denies anything not pre-approved. Use `Ctrl+B` to background a running task mid-execution.

**Resuming subagents:** After a subagent finishes, you can continue it: `"Continue that code review and now analyze the authorization logic."` Claude uses `SendMessage` with the agent's ID; the full conversation history is preserved.

**Disabling built-in subagents:**
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

- Restrict `tools` intentionally. A security auditor has no business writing files.
- Use cheaper models (`haiku`) for read-only exploration; save `sonnet`/`opus` for complex work.
- Personal agents in `~/.claude/agents/` are available across all projects.

> **Sources:** [Lessons from Building Claude Code: How We Use Skills](https://x.com/trq212/status/2033949937936085378) · [Anatomy of the .claude/ Folder](https://x.com/akshay_pachaar/status/2035341800739877091) · [skills.md](../research/sources/skills.md) · [sub-agents.md](../research/sources/sub-agents.md) · [sub-agents-guide.md](../research/sources/sub-agents-guide.md)

---

## 5. Lessons from Building Claude Code: Prompt Caching Is Everything

Long-running agentic products like Claude Code are made feasible by **prompt caching**. The Anthropic team monitors cache hit rates and declares incidents (SEVs) when they drop — that's how important this is.

Prompt caching works by **prefix matching**: the API caches everything from the start of the request up to each `cache_control` breakpoint. Any change anywhere in the prefix invalidates everything after it.

### Order Everything for Caching

**Static content first, dynamic content last:**

1. Static system prompt & tools (globally cached)
2. `CLAUDE.md` (cached within a project)
3. Session context (cached within a session)
4. Conversation messages

This sounds simple, but it breaks in subtle ways:
- Putting a timestamp in the system prompt → cache miss every turn
- Shuffling tool definitions non-deterministically → cache miss
- Updating tool parameters mid-session → cache miss

### Use Messages, Not System Prompt Changes

When information becomes outdated (the time, a file changed, plan mode toggled), don't update the system prompt. Pass updates via messages instead — Claude Code uses `<system-reminder>` tags injected into the next user message for exactly this reason.

### Never Change Tools or Models Mid-Session

**Tools:** Adding or removing a tool invalidates the cache for the entire conversation. Instead of removing tools, use `defer_loading` — send lightweight stubs that the model can discover via `ToolSearch` when needed. The stubs stay in the prefix; full schemas load on demand.

**Models:** Prompt caches are model-specific. If you're 100k tokens into a conversation with Opus and want to ask something simple, switching to Haiku is actually more expensive — you'd pay full price to rebuild the cache. If you need a different model, use a subagent with a handoff message.

### Plan Mode Without Breaking the Cache

The naive approach: swap the tool set to read-only tools when entering plan mode. That breaks the cache.

The right approach: keep all tools in the request at all times. Use `EnterPlanMode` and `ExitPlanMode` as tools themselves. Bonus: because `EnterPlanMode` is a tool Claude can call itself, it can autonomously enter plan mode when it detects a hard problem.

### Cache-Safe Compaction

When the context window fills up and compaction happens, the naive implementation (new API call with a different system prompt, no tools) means zero cache reuse — you pay full price for all tokens.

The right approach: use the exact same system prompt, context, and tool definitions as the parent conversation. Prepend the parent messages, append the compaction prompt as the last user message. The cached prefix is reused; only the compaction prompt is new.

> **Monitor your cache hit rate like you monitor uptime.** A few percentage points of cache miss rate can dramatically affect cost and latency. Alert on cache breaks and treat them as incidents.

> **Sources:** [Lessons from Building Claude Code: Prompt Caching Is Everything](https://x.com/trq212/status/2024574133011673516)

---

## 6. Lessons from Building Claude Code: Seeing Like an Agent

Designing tools for Claude is an art. The framework: **give Claude tools shaped to its abilities**. To know what those abilities are, you have to pay attention to its outputs, run experiments, and update your assumptions as models improve.

### Tool Design Evolves With the Model

**The TodoWrite → Task Tool story** is instructive. When Claude Code launched, Claude needed a Todo list to stay on track, plus system reminders every 5 turns. As models improved, those reminders became constraints — Claude thought it had to stick rigidly to the list instead of adapting. The solution: replace `TodoWrite` with the `Task Tool`, designed around multi-agent coordination (dependencies, cross-agent updates) rather than keeping a single model on track.

> As model capabilities increase, the tools your models once needed might now be constraining them. Constantly revisit previous assumptions.

### Don't Add Tools — Use Progressive Disclosure

Claude Code has ~20 tools. The bar to add a new one is high: each tool gives the model one more option to think about. Adding too much to the system prompt to compensate causes **context rot** — the signal-to-noise ratio drops and instruction adherence degrades.

When Claude didn't know enough about how to use Claude Code itself, the solution wasn't adding content to the system prompt or adding a tool. It was a **Claude Code Guide subagent** — a specialized agent with extensive search instructions, spawned only when you ask about Claude Code itself. Capability added, tool count unchanged.

### Tools Must Match How Claude Thinks

The `AskUserQuestion` tool went through three iterations:
1. A parameter on `ExitPlanTool` — confused Claude (plan + questions at once)
2. Modified markdown output format — Claude was inconsistent
3. A dedicated tool — Claude understood it naturally, used it well

The lesson: even a well-designed tool fails if Claude doesn't intuitively understand how to call it. Test with real outputs, not just specs.

> **Sources:** [Lessons from Building Claude Code: Seeing like an Agent](https://x.com/trq212/status/2027463795355095314)

---

## 7. Lessons from Building Claude Code: Working Well Every Day

Operational tips from the Anthropic team on using Claude Code effectively day-to-day.

### Bug Fixing

- Enable the **Slack MCP** — paste a bug thread and say "fix." Zero context switching.
- "Go fix the failing CI tests." Don't micromanage how.
- Point Claude at docker logs to diagnose issues rather than describing symptoms.

### Prompting Well

- **Challenge Claude.** Say "Grill me on these changes and don't make a PR until I pass your test." Use Claude as your reviewer, not just your coder.
- **Make Claude prove it.** "Prove to me this works" — have Claude diff behavior between `main` and your feature branch.
- Enable **"Explanatory" or "Learning" output style** in `/config` to have Claude explain the *why* behind changes, not just make them.

### Subagents

- Append "use subagents" to any request where you want Claude to throw more compute at a problem.
- Offload individual tasks to subagents to keep your main session's context window clean and focused.
- Route permission requests to Opus via a hook for more careful authorization decisions.

### Data & Analytics

- Use the `bq` CLI directly in Claude Code for BigQuery analytics — no SQL context switching.
- Keep a **data skill** checked into your codebase so everyone on the team gets the same query patterns, credentials setup, and common workflows.

### Interactive UX Features Worth Knowing

**`/btw` — side questions without polluting context:**
Ask a quick question while Claude is mid-task. The answer appears in a dismissible overlay and never enters the conversation history. Full visibility into current context, but no tool access. Perfect for "what was the name of that config key again?" without derailing a long-running task.

```text
/btw what was the name of that config file again?
```

`/btw` is the inverse of a subagent: it sees everything in your context but has no tools. A subagent has all tools but starts with an empty context.

**`!` prefix — direct bash without Claude:**
Prefix any input with `!` to run shell commands directly. The command and output are added to context but don't go through Claude's decision loop. Supports `Ctrl+B` to background long-running commands and `Tab` autocomplete from history.

```
! npm test
! git status
```

**PR review status in the footer:**
When on a branch with an open PR, the footer shows a clickable PR link with color-coded review status: green (approved), yellow (pending), red (changes requested), gray (draft), purple (merged). Updates every 60 seconds. Requires `gh` CLI.

**Vim editor mode:**
Enable with `/vim` or configure permanently via `/config`. Full NORMAL/INSERT mode switching, word motions, text objects, `.` to repeat changes.

**Background bash with `Ctrl+B`:**
Background any running Bash task mid-execution. Claude immediately becomes available for new prompts while the command continues. Retrieve output later with `TaskOutput`.

### Headless & Automation Mode

Claude Code isn't only for interactive sessions. Use `claude -p` (print mode) for scripting, CI/CD pipelines, and automation:

```bash
# Non-interactive: run a query and exit
claude -p "Generate a changelog from the last 10 commits"

# Pipe content in
cat error.log | claude -p "Summarize the root cause of these errors"

# Structured JSON output for programmatic use
claude -p "List all TODO comments in src/" --output-format json

# JSON with schema validation
claude -p "Extract main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# Continue a previous session non-interactively
claude -c -p "Add the missing tests we discussed"

# CI/CD: skip permission prompts in trusted environments
claude -p --dangerously-skip-permissions "Run the full test suite and fix failures"
```

**`--bare` mode for CI/CD:**
Skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md. Produces the same result on every machine, regardless of local config. Pass context explicitly with `--append-system-prompt`, `--settings`, `--mcp-config`, `--agents`.

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

> `--bare` will become the default for `-p` in a future release.

**Permission rule syntax for `--allowedTools`:**
Use `Bash(git diff *)` syntax to scope Bash permissions to specific commands. The space before `*` matters — `Bash(git diff *)` matches `git diff HEAD` but not `git diff-index`.

```bash
claude -p "Create a commit for staged changes" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

For fully automated environments, combine `--dangerously-skip-permissions` with strict `deny` rules in `settings.json` to balance automation speed with safety guardrails.

### Visual Interaction

When text isn't the right medium, use the **playground plugin** to generate standalone HTML files that let you interact with Claude visually:

```
/plugin marketplace update claude-plugins-official
/plugin install playground@claude-plugins-official
```

Good uses: architecture diagram exploration, component design iteration, game balancing, layout brainstorming. The key insight: think of a unique way to interact with the model and ask it to express that.

### Terminal Setup

- `/statusline` — customize your status bar to always show context usage and current git branch.
- **Ghostty** is the team's preferred terminal for synchronized rendering and proper unicode support.
- Run `/terminal-setup` to enable `Shift+Enter` for multiline input in VS Code, Alacritty, Zed, and Warp.

> **Sources:** [Claude Code Tips — Boris Cherny](https://x.com/bcherny/status/2017742741636321619) · [Making Playgrounds using Claude Code](https://x.com/trq212/status/2017024445244924382) · [cli-reference.md](../research/sources/cli-reference.md) · [interactive-mode.md](../research/sources/interactive-mode.md) · [headless-programmatic.md](../research/sources/headless-programmatic.md)

---

## 8. Lessons from Building Claude Code: Checkpointing & Rewind

Every file edit Claude makes is automatically tracked before it happens. This gives you a safety net to undo not just the last change, but any earlier point in the session — including the conversation state.

### How It Works

- **Every user prompt** creates a checkpoint capturing the current state of all files Claude has edited
- Checkpoints **persist across sessions** — you can rewind even after resuming
- Automatically cleaned up after 30 days (configurable)
- Only tracks edits made by Claude's file editing tools — bash commands like `mv`, `cp`, `rm` are **not tracked**

### Opening the Rewind Menu

Press `Esc` `Esc` (twice) or type `/rewind`. A scrollable list shows every prompt from the session. Select a point, then choose:

| Action | What it does |
|---|---|
| **Restore code and conversation** | Full revert — code and history go back to that point |
| **Restore conversation** | Rewind chat history, keep current code |
| **Restore code** | Revert files, keep conversation |
| **Summarize from here** | Compress everything from this point forward into a summary |
| **Never mind** | Cancel |

After restoring, the original prompt is placed back into the input field so you can re-send or edit it.

### "Summarize from here" vs. `/compact`

`/compact` compresses the **entire** conversation. "Summarize from here" is surgical: it keeps early context in full detail and only compresses the selected range. You can add instructions to guide what the summary focuses on.

Use it to free context space after a verbose debugging detour — without losing the setup and goals you established at the start.

> If you want to branch and try a different approach while preserving the original session intact, use `claude --continue --fork-session` instead.

### When to Use Checkpoints

- **Exploring alternatives** — try an approach knowing you can get back to square one
- **Recovering from mistakes** — a bad refactor, an accidental deletion
- **Freeing context mid-task** — summarize a debugging rabbit hole before continuing

> **Sources:** [checkpointing.md](../research/sources/checkpointing.md)

---

## 9. Lessons from Building Claude Code: Scheduled Tasks & `/loop`

Claude Code can run prompts on a recurring schedule — without leaving your terminal or writing a cron job. Tasks are session-scoped: they live while Claude is running and disappear on exit.

### Schedule a Recurring Check

```text
/loop 5m check if the deployment finished and tell me what happened
```

Claude parses the interval, creates a cron job, and confirms the schedule. The task fires between turns — it waits if Claude is mid-response.

**Interval syntax:**

| Form | Example | Result |
|---|---|---|
| Leading token | `/loop 30m check the build` | Every 30 minutes |
| Trailing clause | `/loop check the build every 2 hours` | Every 2 hours |
| No interval | `/loop check the build` | Every 10 minutes (default) |

**Supported units:** `s` (seconds), `m` (minutes), `h` (hours), `d` (days).

### Loop Over a Slash Command

```text
/loop 20m /review-pr 1234
```

Each time the job fires, Claude runs `/review-pr 1234` as if you'd typed it manually.

### One-Time Reminders

Use natural language instead of `/loop` for one-shot tasks:

```text
remind me at 3pm to push the release branch
```

```text
in 45 minutes, check whether the integration tests passed
```

Claude creates a single-fire task that deletes itself after running.

### Manage Tasks

```text
what scheduled tasks do I have?
cancel the deploy check job
```

Under the hood: `CronCreate`, `CronList`, `CronDelete` tools. Max 50 tasks per session.

### Key Behaviors

- Tasks fire **between turns**, never mid-response
- **No catch-up** for missed fires — fires once when Claude next becomes idle
- **Recurring tasks expire after 3 days** — cancel and recreate to extend
- All times are in **local timezone** (not UTC)
- Jitter is applied to avoid API spikes at exact wall-clock minutes
- Disable entirely: `CLAUDE_CODE_DISABLE_CRON=1`

> For scheduling that survives restarts, see Desktop scheduled tasks or GitHub Actions. To react to events as they happen instead of polling, see Channels (Section 10).

> **Sources:** [scheduled-tasks.md](../research/sources/scheduled-tasks.md)

---

## 10. Lessons from Building Claude Code: Channels — Push Events Into Sessions

Channels are MCP servers that push external events into your running Claude Code session. Instead of Claude polling, the world notifies Claude.

> **Research preview** — requires Claude Code v2.1.80+, claude.ai login (not Console/API key).

### The Key Difference From MCP

A standard MCP server is **pull**: Claude queries it during a task. A **channel** is **push**: an external source sends a message and Claude reacts to it in real time, without you being at the terminal.

### Supported Channels

**Telegram** — ask Claude from your phone; answers come back in the chat while work runs on your machine against real files:

```text
/plugin install telegram@claude-plugins-official
/telegram:configure <token>
claude --channels plugin:telegram@claude-plugins-official
```

**Discord** — same flow, different platform:

```text
/plugin install discord@claude-plugins-official
/discord:configure <token>
claude --channels plugin:discord@claude-plugins-official
```

After installing, pair your account by sending a message to the bot → get a pairing code → `/telegram:access pair <code>` → lock down with `/telegram:access policy allowlist`.

### Use Cases

- **Chat bridge** — ask Claude from mobile while a long build runs on your machine
- **Webhook receiver** — CI failure, error tracker alert, or deploy event arrives where Claude already has your files open
- **Permission relay** — channels can forward permission prompts to you remotely if you're away from the terminal

### Security Model

Each channel maintains a **sender allowlist** — only IDs you've explicitly approved can push messages. Everyone else is silently dropped. The `--channels` flag controls which servers are active per session; being in `.mcp.json` alone is not enough.

### How It Compares to Other Remote Options

| Feature | What it does | Good for |
|---|---|---|
| Claude Code on the web | Cloud sandbox, cloned from GitHub | Delegating async work |
| Claude in Slack | Spawns web session from `@Claude` | Starting tasks from team chat |
| Standard MCP server | Claude queries on demand | Read/query a system |
| Remote Control | Drive local session from claude.ai | Steering from another device |
| **Channels** | Push events from outside into running session | Chat bridge, webhooks, CI notifications |

> **Sources:** [channels.md](../research/sources/channels.md)

---

## 11. Lessons from Building Claude Code: Agent Teams

Agent Teams take parallelism to its logical conclusion: instead of a single Claude session spawning isolated subagents, you get a coordinated group of Claude Code instances that share a task list and can message each other directly.

> **Experimental** — disabled by default. Requires Claude Code v2.1.32+.

Enable:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### How It Works

- One session is the **team lead**: creates the team, spawns teammates, synthesizes results
- **Teammates** each run in their own context window, fully independent
- A **shared task list** coordinates work (tasks: pending → in progress → completed, with dependency tracking)
- A **mailbox system** allows direct inter-agent messaging — teammates can debate, share findings, challenge each other's conclusions

This is what makes teams different from subagents: subagents report back only to the main agent; teammates can talk to each other.

### Subagents vs. Agent Teams

| | Subagents | Agent Teams |
|---|---|---|
| **Context** | Own window; results return to caller | Own window; fully independent |
| **Communication** | Report back to main only | Teammates message each other directly |
| **Coordination** | Main agent manages everything | Shared task list with self-coordination |
| **Token cost** | Lower (results summarized) | Higher (each teammate = separate Claude instance) |
| **Best for** | Focused tasks, result matters most | Complex work needing collaboration and debate |

### When to Use Agent Teams

**Best for:**
- Research with multiple angles investigated simultaneously
- New features where teammates each own a separate module
- Debugging with competing hypotheses — teammates can try to disprove each other
- Cross-layer work: frontend, backend, tests each owned by different teammate

**Not for:**
- Sequential tasks, same-file edits, or work with many shared dependencies → use a single session or subagents

### Starting a Team

```text
I'm designing a CLI tool that helps developers track TODO comments.
Create an agent team to explore this from different angles: one teammate on UX,
one on technical architecture, one playing devil's advocate.
```

### Display Modes

| Mode | Description |
|---|---|
| `in-process` | All teammates inside main terminal; `Shift+Down` to cycle |
| `tmux` | Each teammate in its own pane |
| `auto` (default) | Split panes if already in tmux, otherwise in-process |

```json
{ "teammateMode": "in-process" }
```

### Controlling the Team

- **Specify models per teammate:** `"Use Sonnet for each teammate"`
- **Require plan approval:** `"Spawn an architect teammate to refactor auth. Require plan approval before any changes."` — teammate works in read-only plan mode, sends approval request to lead, lead approves/rejects with feedback
- **Talk to teammates directly:** `Shift+Down` to cycle, then type; `Ctrl+T` to toggle task list
- **Shutdown:** always use the lead to clean up (`"Clean up the team"`)

### Hooks for Quality Gates

- **`TeammateIdle`** — fires when a teammate finishes. Exit 2 → send feedback and keep them working
- **`TaskCompleted`** — fires when a task is about to be marked complete. Exit 2 → prevent completion with feedback

Use these to enforce review gates: a teammate can't declare work done without passing your checks.

### Best Practices

- Give enough context in the spawn prompt — teammates don't inherit the lead's conversation history
- Start with 3–5 teammates (balance parallelism vs. coordination overhead)
- 5–6 tasks per teammate is a good load
- Avoid file conflicts — design tasks so each teammate owns different files
- Start with research/review before parallel implementation if new to teams

### Current Limitations

- No session resumption for in-process teammates (`/resume` doesn't restore teammates)
- No nested teams (teammates can't spawn their own teams)
- One team per session
- Split panes require tmux or iTerm2 (not VS Code terminal, Windows Terminal, or Ghostty)

> **Sources:** [agent-teams.md](../research/sources/agent-teams.md)

---

## Quick Reference

| Concept | Key Insight |
|---|---|
| Context window | Everything Claude knows per turn — keep it lean |
| Context rot | Too much generic content in the prompt → instruction adherence drops |
| `CLAUDE.md` | Highest-leverage file. Under 200 lines. Team-committed. |
| `@import` | Pull external files into CLAUDE.md without bloating it |
| `rules/` | Split `CLAUDE.md` as it grows. Scope rules by path. |
| Auto memory | Claude saves learnings across sessions. Browse with `/memory`. |
| Commands | Manual trigger. Single file. `$ARGUMENTS` for params. |
| Skills | Auto-triggered. Folder with progressive disclosure. Description = trigger condition. |
| Agents | Isolated context. Restrict tools. Route model by task type. Advanced: `memory`, `hooks`, `isolation`, `permissionMode`. |
| Hooks | 4 types: `command`, `prompt` (LLM), `agent` (multi-turn), `http`. Block, log, automate. |
| MCP | External tools (Slack, DB, browser). Commit `.mcp.json` for team sharing. |
| Prompt caching | Prefix match. Static first. Never change tools/models mid-session. |
| Subagents | More compute. Clean main context. Different model per task. Resume with full history. |
| `claude -p` | Non-interactive/headless mode for scripts and CI/CD. |
| `--bare` | CI mode: skips hooks, skills, MCP, CLAUDE.md. Same result on every machine. |
| `/btw` | Side question with no context pollution. Works while Claude is processing. |
| `! cmd` | Direct bash without Claude. Output added to context. |
| Checkpointing | Auto-tracks file edits. `Esc+Esc` to rewind. "Summarize from here" = surgical `/compact`. |
| `/loop` | Session-scoped cron. `/loop 5m check the build`. Max 50 tasks, expires in 3 days. |
| Channels | Push-based events into running session (Telegram, Discord). Inverse of MCP pull. |
| Agent Teams | Multiple Claude instances, shared task list, inter-agent messaging. Experimental. |
| Progressive disclosure | Load only what's needed, when it's needed. |
