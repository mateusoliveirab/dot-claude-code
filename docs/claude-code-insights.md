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
| `SubagentStart` / `SubagentStop` | When a subagent is spawned/finishes | — |
| `PreCompact` / `PostCompact` | Before/after context compaction | — |
| `Notification` | When Claude sends a notification | — |
| `InstructionsLoaded` | When a CLAUDE.md or rules file loads | — |
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

The hook script receives JSON on stdin with full context about the event (tool name, inputs, outputs, session info). It can exit 0 (allow), exit 2 (block with message), or return JSON with a `permissionDecision`.

### What to Build With Hooks

**Safety guardrails:**
- Block `rm -rf`, `DROP TABLE`, force-push, `kubectl delete` via `PreToolUse` on Bash
- Deny reads to `.env` or secrets directories
- Route permission requests to a stronger model (Opus) for human-level judgment

**Observability:**
- Log every tool call to a file or analytics system
- Measure skill usage via `PreToolUse` — track which skills trigger and how often
- Send a desktop notification via `Stop` when Claude finishes a long task

**Workflow automation:**
- Run your test suite automatically after every file edit (`PostToolUse` on Write/Edit)
- Post a summary to Slack when a task completes
- Trigger CI/CD pipelines on `SessionEnd`

**Context injection:**
- Use `SessionStart` to set up environment variables or run initialization scripts
- Use `InstructionsLoaded` to log exactly which instruction files were loaded (useful for debugging path-scoped rules)

### Hooks in Skills (On-Demand)

Skills can register hooks that activate **only for the duration of that session**. This is a powerful pattern for opinionated workflows you don't want running all the time:

- `/careful` — activates a `PreToolUse` hook that blocks destructive commands during a risky session
- `/freeze` — blocks any Edit/Write outside a specific directory (useful when debugging: "add logs but don't touch anything else")

Hooks can also run **asynchronously** (fire-and-forget), so they don't block Claude's loop — useful for logging, notifications, and CI triggers.

> **Sources:** [hooks.md](../research/sources/hooks.md)

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
model: sonnet
tools: Read, Grep, Glob
---
You are a senior code reviewer focused on correctness and maintainability.
```

- Restrict `tools` intentionally. A security auditor has no business writing files.
- Use cheaper models (`haiku`) for read-only exploration; save `sonnet`/`opus` for complex work.
- Personal agents in `~/.claude/agents/` are available across all projects.

> **Sources:** [Lessons from Building Claude Code: How We Use Skills](https://x.com/trq212/status/2033949937936085378) · [Anatomy of the .claude/ Folder](https://x.com/akshay_pachaar/status/2035341800739877091) · [skills.md](../research/sources/skills.md) · [sub-agents.md](../research/sources/sub-agents.md)

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

### Headless & Automation Mode

Claude Code isn't only for interactive sessions. Use `claude -p` (print mode) for scripting, CI/CD pipelines, and automation:

```bash
# Non-interactive: run a query and exit
claude -p "Generate a changelog from the last 10 commits"

# Pipe content in
cat error.log | claude -p "Summarize the root cause of these errors"

# Structured JSON output for programmatic use
claude -p "List all TODO comments in src/" --output-format json

# Continue a previous session non-interactively
claude -c -p "Add the missing tests we discussed"

# CI/CD: skip permission prompts in trusted environments
claude -p --dangerously-skip-permissions "Run the full test suite and fix failures"
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

> **Sources:** [Claude Code Tips — Boris Cherny](https://x.com/bcherny/status/2017742741636321619) · [Making Playgrounds using Claude Code](https://x.com/trq212/status/2017024445244924382) · [cli-reference.md](../research/sources/cli-reference.md)

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
| Agents | Isolated context. Restrict tools. Route model by task type. |
| Hooks | Shell/HTTP/LLM triggers at lifecycle events. Block, log, automate. |
| MCP | External tools (Slack, DB, browser). Commit `.mcp.json` for team sharing. |
| Prompt caching | Prefix match. Static first. Never change tools/models mid-session. |
| Subagents | More compute. Clean main context. Different model per task. |
| `claude -p` | Non-interactive/headless mode for scripts and CI/CD. |
| Progressive disclosure | Load only what's needed, when it's needed. |
