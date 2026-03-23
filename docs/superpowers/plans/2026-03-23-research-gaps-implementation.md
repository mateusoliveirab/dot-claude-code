# Research Gaps Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all identified gaps between research sources and the repo's actual configuration, closing the delta between what was researched and what's shipped.

**Architecture:** 7 independent workstreams (settings, env, rules, hooks, skills, agents, docs). Each workstream produces self-contained changes. No cross-dependencies except that settings.json is touched by multiple workstreams — merge carefully.

**Tech Stack:** Bash, Markdown, JSON (jq for validation)

---

## File Map

### Modified Files
- `global/settings.json` — permissions rewrite, env vars, hooks, schema, plugins
- `global/CLAUDE.md` — add references to new rules
- `global/rules/working-approach.md` — add checkpointing and prompt-caching notes
- `global/skills/README.md` — update available skills table
- `templates/skill-template/SKILL.md` — add Gotchas section

### New Files — Rules
- `global/rules/prompt-caching.md` — prompt cache preservation practices
- `global/rules/advanced-features.md` — checkpointing, /btw, output styles, --bare

### New Files — Skills
- `global/skills/adversarial-review/SKILL.md` — fresh-eyes code critique subagent
- `global/skills/careful/SKILL.md` — on-demand safety hooks for dangerous commands
- `global/skills/freeze/SKILL.md` — on-demand edit restriction to specific directory
- `global/skills/babysit-pr/SKILL.md` — PR monitoring with /loop

### New Files — Agents
- `global/agents/code-reviewer.md` — everyday code review subagent
- `global/agents/debugger.md` — systematic debugging subagent

---

## Task 1: Fix settings.json — Permissions, Schema, Env Vars, Hooks

**Files:**
- Modify: `global/settings.json`

This is the largest single change. Rewrites permissions to canonical string syntax, adds env vars, notification hook, and schema.

- [ ] **Step 1: Read current settings.json and understand structure**

Already read. Current state uses `alwaysAllow`/`alwaysDeny` with object format. Canonical format uses `allow`/`deny`/`ask` with string rules.

- [ ] **Step 2: Rewrite settings.json with all fixes**

Complete rewrite incorporating:

**GAP-S1** — Add `$schema`
**GAP-S5** — Rewrite permissions to canonical `allow`/`deny`/`ask` string syntax
**GAP-S6** — Add `ask` tier for confirmable operations
**GAP-S3** — Add `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR: "1"` in env
**GAP-E1** — Add `includeGitInstructions: false` (skills replace built-in)
**GAP-E3** — Add `BASH_MAX_OUTPUT_LENGTH` (RTK-aligned)
**GAP-E4** — Add `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY: "1"`
**GAP-H1** — Add `Notification` hook with `notify-send`
**GAP-M2** — Add `enableAllProjectMcpServers: true`
**GAP-SK7** — Enable `playground` plugin

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run build:*)",
      "Bash(npm run lint:*)",
      "Bash(npx eslint:*)",
      "Bash(pkill:*)",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git branch*)",
      "Read(src/**/*)",
      "Read(app/**/*)",
      "Read(components/**/*)",
      "Read(lib/**/*)",
      "Read(*.md)",
      "Read(*.json)",
      "Grep(**/*.ts)",
      "Grep(**/*.tsx)",
      "Grep(**/*.js)",
      "Grep(**/*.jsx)",
      "Glob(**/*)",
      "mcp__chrome-devtools__navigate_page",
      "mcp__chrome-devtools__evaluate_script",
      "mcp__chrome-devtools__take_snapshot",
      "mcp__chrome-devtools__click",
      "mcp__chrome-devtools__fill",
      "mcp__chrome-devtools__take_screenshot",
      "mcp__chrome-devtools__emulate",
      "mcp__chrome-devtools__resize_page",
      "mcp__chrome-devtools__wait_for",
      "mcp__chrome-devtools__list_pages",
      "mcp__chrome-devtools__new_page",
      "mcp__shadcn-ui__get_component"
    ],
    "ask": [
      "Bash(git push*)",
      "Bash(git rebase*)",
      "Bash(docker *)",
      "Bash(kubectl *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git push * --force*)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Write(./.env)",
      "Write(./.env.*)",
      "Write(**/credentials.json)",
      "Write(**/secrets.json)"
    ],
    "defaultMode": "default"
  },
  "env": {
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
    "BASH_MAX_OUTPUT_LENGTH": "30000",
    "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY": "1"
  },
  "includeGitInstructions": false,
  "enableAllProjectMcpServers": true,
  "statusLine": {
    "type": "command",
    "command": "bash $HOME/.claude/statusline-command.sh"
  },
  "alwaysThinkingEnabled": true,
  "effortLevel": "high",
  "promptSuggestionEnabled": false,
  "voiceEnabled": true,
  "showThinkingSummaries": true,
  "skipDangerousModePermissionPrompt": true,
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "playground@claude-plugins-official": true
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/rtk-rewrite.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // empty' | (read -r f && { [[ \"$f\" == *.sh ]] || exit 0; bash -n \"$f\"; }) 2>/dev/null",
            "timeout": 10,
            "statusMessage": "Checking shell syntax..."
          },
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // empty' | (read -r f && { [[ \"$f\" == *.json ]] || exit 0; jq empty \"$f\"; }) 2>/dev/null",
            "timeout": 10,
            "statusMessage": "Validating JSON..."
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Claude Code needs your attention'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 3: Validate JSON**

Run: `jq empty global/settings.json`
Expected: no output (valid JSON)

- [ ] **Step 4: Commit**

```bash
git add global/settings.json
git commit -m "fix(settings): canonical permissions, env vars, notification hook, schema"
```

---

## Task 2: New Rule — Prompt Caching Best Practices

**Files:**
- Create: `global/rules/prompt-caching.md`

Covers GAP-R2 — non-obvious practices that break prompt cache.

- [ ] **Step 1: Create the rule file**

```markdown
---
description: Prompt caching awareness — avoid patterns that break cache and increase cost/latency
---

# Prompt Caching

Prompt caching works by prefix matching. Any change in the prefix invalidates everything after it.

## What Breaks Cache

- Changing tools mid-session (adding/removing MCP servers, toggling tool access)
- Switching models mid-conversation (each model has its own cache)
- Timestamps or dynamic content in system prompts
- Non-deterministic tool ordering

## Safe Patterns

- Use system-reminder messages (next user turn) for dynamic updates instead of editing system prompt
- Use subagents to delegate to different models (Haiku for exploration, Opus for complex work) — subagents have their own cache
- Use `EnterPlanMode`/`ExitPlanMode` tools instead of swapping tool sets
- Use `ToolSearch` deferred loading instead of removing tools

## CLAUDE.md Implications

- Keep CLAUDE.md stable within a session — edits force cache rebuild
- Front-load static content, put dynamic content last
- Avoid `!backtick` commands that produce non-deterministic output in CLAUDE.md
```

- [ ] **Step 2: Validate markdown has frontmatter**

Run: `head -3 global/rules/prompt-caching.md`
Expected: `---` / `description:` / `---`

- [ ] **Step 3: Commit**

```bash
git add global/rules/prompt-caching.md
git commit -m "feat(rules): add prompt-caching best practices"
```

---

## Task 3: New Rule — Advanced Features Reference

**Files:**
- Create: `global/rules/advanced-features.md`

Covers GAP-C1 (checkpointing), GAP-C3 (output styles), GAP-C4 (/btw), GAP-C2 (--bare), GAP-R5 (!backtick), GAP-R6 ($CLAUDE_SKILL_DIR), GAP-R1 (path-scoped rules), GAP-A1 (agent teams).

- [ ] **Step 1: Create the rule file**

```markdown
---
description: Advanced Claude Code features reference — checkpointing, output styles, path-scoped rules, agent teams
---

# Advanced Features

## Checkpointing & Rewind

`Esc+Esc` or `/rewind` opens the checkpoint menu. Options:
- Restore code + conversation to a checkpoint
- Restore code only (keep conversation)
- Restore conversation only (keep code changes)
- Selective compaction from a specific point

Use after risky operations or when Claude goes off-track.

## Side Questions

`/btw <question>` asks a quick side question without interrupting the main task context. Use for clarifications that shouldn't derail the current workflow.

## Output Styles

`/config outputStyle` changes response style:
- `"Explanatory"` — explains the *why* behind changes (useful for learning)
- Default — concise, action-oriented

## Path-Scoped Rules

Rules can target specific file patterns via `paths:` frontmatter:

```yaml
---
description: API conventions
paths: ["src/api/**/*.ts", "src/routes/**/*.ts"]
---
```

The rule only loads when Claude reads/edits files matching those patterns.

## Skill Variables

- `${CLAUDE_SKILL_DIR}` — resolves to the skill's directory at runtime. Use for portable script paths instead of hardcoding `~/.claude/skills/...`
- `!backtick` syntax in skill files runs shell commands and embeds output at load time (dynamic context injection)

## Headless / CI Mode

`claude --bare -p "prompt"` skips hooks, skills, plugins, MCP, auto-memory, and CLAUDE.md. Use for reproducible CI/CD scripts.

## Agent Teams (Experimental)

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` enables multi-session coordination. Use subagents for most cases — agent teams are for genuinely independent parallel sessions that need to communicate.
```

- [ ] **Step 2: Commit**

```bash
git add global/rules/advanced-features.md
git commit -m "feat(rules): add advanced features reference"
```

---

## Task 4: Update Existing Files — Template, Working Approach, CLAUDE.md

**Files:**
- Modify: `templates/skill-template/SKILL.md` — add Gotchas section (GAP-R3)
- Modify: `global/rules/working-approach.md` — add checkpoint mention
- Modify: `global/CLAUDE.md` — reference new rules
- Modify: `global/skills/README.md` — add new skills to table

- [ ] **Step 1: Add Gotchas section to skill template**

In `templates/skill-template/SKILL.md`, rename "Edge Cases" to "Gotchas" and rewrite:

```markdown
## Gotchas

> The highest-signal content in any skill. Build this up from real failure modes over time.

- **Gotcha 1**: Description of a non-obvious failure mode and how to avoid it
- **Gotcha 2**: Description of another common pitfall
```

- [ ] **Step 2: Add checkpoint note to working-approach.md**

Append after "Fast Mode Usage" section:

```markdown

## Recovery

- Use `Esc+Esc` or `/rewind` to restore code and/or conversation to a checkpoint after mistakes
- Checkpoints are automatic — no manual save needed
```

- [ ] **Step 3: Update global/CLAUDE.md to reference new rules**

Add to the "Extended Guidelines" section:

```markdown
- `prompt-caching.md` — Avoid breaking prompt cache
- `advanced-features.md` — Checkpointing, output styles, path-scoped rules
```

- [ ] **Step 4: Update skills README table**

Add new skills to the Available Skills table:

```markdown
| `adversarial-review` | Fresh-eyes code critique via subagent | `/adversarial-review` |
| `careful` | On-demand safety hooks for dangerous commands | `/careful` |
| `freeze` | Restrict edits to a specific directory | `/freeze` |
| `babysit-pr` | Monitor PR, retry CI, resolve conflicts | `/babysit-pr` |
```

- [ ] **Step 5: Commit**

```bash
git add templates/skill-template/SKILL.md global/rules/working-approach.md global/CLAUDE.md global/skills/README.md
git commit -m "feat: update template gotchas, working-approach, CLAUDE.md refs, skills table"
```

---

## Task 5: New Skill — adversarial-review

**Files:**
- Create: `global/skills/adversarial-review/SKILL.md`

Covers GAP-SK1. Spawns a fresh-eyes subagent to critique code, implements fixes, iterates.

- [ ] **Step 1: Create skill directory and SKILL.md**

```bash
mkdir -p global/skills/adversarial-review
```

```markdown
---
name: adversarial-review
description: Fresh-eyes code review via subagent. Use when completing a feature, before creating a PR, or when the user says "review", "critique", "grill me", or "challenge these changes".
---

# Adversarial Review

Spawns an independent subagent with no prior context to critique the current changes. Iterates until findings degrade to nitpicks.

## Workflow

1. **Identify scope** — determine what changed (diff against base branch, or staged files)
2. **Spawn reviewer subagent** with:
   - `model: sonnet` (fresh perspective, cost-effective)
   - `tools: Read, Grep, Glob, Bash` (read-only + git commands)
   - Prompt: "You are a senior engineer reviewing this diff for the first time. Be thorough and direct. Flag: bugs, security issues, logic errors, missing edge cases, unclear naming, performance concerns. Skip style nitpicks unless they hurt readability. For each finding, cite the exact file:line."
3. **Receive findings** — present to user grouped by severity (bugs > security > logic > style)
4. **Implement fixes** — for each accepted finding, apply the fix
5. **Re-review** — spawn a new subagent to review the fixes. Iterate until findings are nitpick-level only
6. **Report** — summarize what was found, fixed, and what remains as known trade-offs

## Gotchas

- Always diff against the base branch, not just staged changes — catches drift from main
- The reviewer subagent must NOT see the implementation conversation — fresh eyes means fresh context
- Don't auto-fix everything. Present findings and let the user choose what to address
- If the diff is too large (>2000 lines), split review by file/module and dispatch parallel subagents
```

- [ ] **Step 2: Commit**

```bash
git add global/skills/adversarial-review/
git commit -m "feat(skills): add adversarial-review skill"
```

---

## Task 6: New Skills — careful and freeze

**Files:**
- Create: `global/skills/careful/SKILL.md`
- Create: `global/skills/freeze/SKILL.md`

Covers GAP-SK2. On-demand session-scoped safety hooks.

- [ ] **Step 1: Create careful skill**

```bash
mkdir -p global/skills/careful
```

```markdown
---
name: careful
description: Activate session-scoped safety hooks that block dangerous commands (rm -rf, DROP TABLE, force-push, kubectl delete). Use when working in production, sensitive environments, or when the user says "be careful", "careful mode", or "/careful".
---

# Careful Mode

Registers `PreToolUse` hooks for the current session that block destructive commands before they execute.

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

1. **Announce** — "Careful mode activated. Blocking destructive commands for this session."
2. **Register hooks** — The skill itself defines the hooks. When activated, Claude will refuse to execute any Bash command matching the blocked patterns above.
3. **Operate normally** — all other commands work as usual
4. **User can override** — if the user explicitly says "I need to run this, override careful mode", allow it with a warning

## Gotchas

- This is session-scoped only — it does NOT persist across sessions
- Pattern matching is substring-based. `rm -rf` also catches `sudo rm -rf`
- Cannot catch commands composed via pipes or scripts that internally run destructive operations
- If you need permanent blocks, use `deny` rules in `settings.json` instead
```

- [ ] **Step 2: Create freeze skill**

```bash
mkdir -p global/skills/freeze
```

```markdown
---
name: freeze
description: Restrict all file edits to a specific directory for the current session. Use when debugging, when the user says "freeze", "only edit in X", or "don't touch anything outside X". Prevents accidental changes to unrelated code.
---

# Freeze Mode

Restricts all Write/Edit operations to a specified directory for the session duration.

## Usage

```
/freeze src/api/
/freeze .  (current directory only)
```

## Workflow

1. **Accept target directory** — the user specifies which directory is writable. Default: current working directory
2. **Announce** — "Freeze mode: edits restricted to `<directory>`. All other paths are read-only."
3. **Enforce** — before any Write or Edit tool call, verify the target path is within the frozen directory. If not, refuse and explain
4. **User can unfreeze** — "unfreeze" or "remove freeze" disables the restriction

## Gotchas

- Only restricts Claude's Write/Edit tool calls — Bash commands that write files are NOT blocked (use `/careful` for that)
- Relative paths are resolved against the project root
- Does not restrict Read/Grep/Glob — those remain unrestricted for exploration
```

- [ ] **Step 3: Commit**

```bash
git add global/skills/careful/ global/skills/freeze/
git commit -m "feat(skills): add careful and freeze session-safety skills"
```

---

## Task 7: New Skill — babysit-pr

**Files:**
- Create: `global/skills/babysit-pr/SKILL.md`

Covers GAP-SK6. PR monitoring using `/loop`.

- [ ] **Step 1: Create babysit-pr skill**

```bash
mkdir -p global/skills/babysit-pr
```

```markdown
---
name: babysit-pr
description: Monitor a PR — retry flaky CI, resolve merge conflicts, enable auto-merge. Use when the user says "babysit this PR", "watch this PR", "monitor PR", or wants to automate PR lifecycle after submission.
---

# Babysit PR

Monitors a pull request until it merges or the user cancels. Uses `/loop` for periodic polling.

## Workflow

1. **Identify PR** — get the PR number/URL from the user or detect from current branch
2. **Start monitoring loop** — use `/loop 5m` to check every 5 minutes:
   - `git fetch origin && git log --oneline origin/main..HEAD` — check for new commits on main
   - Check CI status via `gh pr checks <number>` or `git log` for status
   - Check for merge conflicts
3. **On CI failure:**
   - If flaky test (same test passed before): retry CI
   - If real failure: notify user with failure details and stop
4. **On merge conflict:**
   - Attempt automatic resolution: `git fetch origin main && git rebase origin/main`
   - If conflict is trivial (lockfile, auto-generated): resolve and force-push
   - If conflict requires judgment: notify user and stop
5. **On all checks green + approved:**
   - Enable auto-merge if available, or notify user "PR is ready to merge"
6. **Report** — on each loop iteration, log status silently. Only notify on state changes

## Gotchas

- Never force-push to someone else's PR branch
- Flaky test detection: compare against the last 3 runs of the same test, not just one
- Rate limit awareness: don't poll GitHub API more than once per minute
- Always stop after merge — don't leave orphan loops running
- Requires `gh` CLI authenticated, or falls back to `git` commands only
```

- [ ] **Step 2: Commit**

```bash
git add global/skills/babysit-pr/
git commit -m "feat(skills): add babysit-pr monitoring skill"
```

---

## Task 8: New Agent — code-reviewer

**Files:**
- Create: `global/agents/code-reviewer.md`

Covers GAP-SK3 and GAP-A2. Everyday code review subagent with persistent memory.

- [ ] **Step 1: Create agent file**

```markdown
---
name: code-reviewer
description: Reviews code for quality, bugs, and best practices. Use proactively after writing or modifying code, before commits, or when the user asks for a review. Lightweight and fast — designed for everyday use, not just PR reviews.
model: sonnet
tools: Read, Grep, Glob, Bash
memory: project
---

You are a senior code reviewer. Your job is to catch bugs, security issues, and logic errors before they reach production.

## Review Priorities (in order)

1. **Bugs** — logic errors, off-by-one, null/undefined access, race conditions
2. **Security** — injection, auth bypass, secrets in code, unsafe deserialization
3. **Edge cases** — empty input, boundary values, error paths not handled
4. **API contracts** — breaking changes, missing validation, inconsistent responses
5. **Performance** — N+1 queries, unbounded loops, missing pagination, memory leaks
6. **Clarity** — misleading names, dead code, overly clever abstractions

## What NOT to flag

- Style preferences (formatting, bracket placement) — that's what linters are for
- Minor naming suggestions unless the current name is actively misleading
- "Consider adding tests" without specifying what test and why
- Theoretical concerns that don't apply to the actual code path

## Output Format

For each finding:
```
**[severity]** file:line — description
  Why: concrete explanation of what could go wrong
  Fix: specific suggestion (not "consider refactoring")
```

Severities: `BUG`, `SECURITY`, `EDGE_CASE`, `PERF`, `CLARITY`

## Behavior

- Review only the diff, not the entire file (unless context is needed to understand the change)
- If the diff is clean and well-written, say so briefly. Don't manufacture findings.
- Use your project memory to track recurring patterns — if you've flagged the same issue before, reference it
```

- [ ] **Step 2: Commit**

```bash
git add global/agents/code-reviewer.md
git commit -m "feat(agents): add code-reviewer subagent"
```

---

## Task 9: New Agent — debugger

**Files:**
- Create: `global/agents/debugger.md`

Covers GAP-SK4. Systematic debugging subagent.

- [ ] **Step 1: Create agent file**

```markdown
---
name: debugger
description: Systematic debugging agent. Use when encountering errors, test failures, or unexpected behavior. Captures error state, isolates the root cause, applies minimal fix, and verifies. Delegate to this agent instead of debugging inline when the issue is non-trivial.
model: sonnet
tools: Read, Grep, Glob, Bash
memory: project
---

You are a systematic debugger. Your job is to find the root cause, not apply bandaids.

## Debugging Protocol

1. **Reproduce** — run the failing command/test and capture the exact error output
2. **Read the error** — parse stack traces, error codes, and messages literally. Don't guess.
3. **Hypothesize** — form exactly one hypothesis about the root cause based on the error
4. **Verify** — find evidence that confirms or refutes the hypothesis. Read the relevant code.
5. **If refuted** — go back to step 3 with a new hypothesis. Don't iterate on a wrong theory.
6. **Fix** — apply the minimal change that addresses the root cause
7. **Verify fix** — run the original failing command. It must pass.
8. **Check for collateral** — run related tests to ensure the fix didn't break anything else

## Rules

- Never apply a fix without reproducing the error first
- Never apply more than one fix at a time — if the first fix doesn't work, revert before trying another
- If you can't reproduce the error after 3 attempts, report that and ask for more context
- Log your hypothesis chain — what you thought, what you checked, what you found
- Use your project memory to track recurring bugs and their root causes

## Anti-Patterns

- Adding `try/catch` to silence an error without understanding it
- Fixing the symptom (wrong output) instead of the cause (wrong input)
- "It works on my machine" — if the test fails, the code is wrong
- Changing multiple things at once — you won't know which one fixed it
```

- [ ] **Step 2: Commit**

```bash
git add global/agents/debugger.md
git commit -m "feat(agents): add debugger subagent"
```

---

## Task 10: Validation

- [ ] **Step 1: Validate all JSON files**

```bash
jq empty global/settings.json
jq empty global/mcp.json
```

- [ ] **Step 2: Validate all bash scripts**

```bash
bash -n install.sh
```

- [ ] **Step 3: Dry-run install**

```bash
bash install.sh --dry-run
```

- [ ] **Step 4: Verify no secrets committed**

```bash
grep -r "password\|secret\|api_key\|token" global/ --include="*.json" --include="*.md" -l
```

Expected: no results or only documentation references

---

## Gaps Intentionally Skipped (obvious or low-value for senior/AI audience)

- **GAP-S2** (`autoUpdatesChannel`): personal preference, not a config repo concern
- **GAP-S4** (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`): default 95% is reasonable, tuning is situational
- **GAP-S7** (worktree settings): only relevant for monorepos, not this config repo
- **GAP-S8** (sandbox docs): sandbox is well-documented in official docs, just toggle `sandbox.enabled`
- **GAP-E2** (`CLAUDE_CODE_SHELL`): only needed when login shell doesn't match — edge case
- **GAP-R4** (skill config.json pattern): already implied by existing skill template
- **GAP-H2** (SessionStart compact re-injection): overly complex for marginal benefit
- **GAP-H3** (Stop hook verification): the PostToolUse hooks already validate
- **GAP-H4** (skill usage logging): premature optimization — measure when you have 20+ skills
- **GAP-SK5** (standup/weekly-recap): team-specific, not generalizable
- **GAP-A3** (isolation: worktree in agents): the `isolation` field is documented, agents can use it per-project
- **GAP-A4** (Haiku explorer agent): built-in Explore agent already does this
- **GAP-M1** (GitHub MCP): `gh` CLI works fine, GitHub MCP adds complexity without clear benefit for this setup
