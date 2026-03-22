---
url: https://x.com/akshay_pachaar/status/2035341800739877091
author: akshay_pachaar
crawled_at: 2026-03-22
tags: [claude-code, dot-claude, configuration, skills, agents, commands, settings, CLAUDE.md]
---

# Anatomy of the .claude/ Folder

A complete guide to CLAUDE.md, custom commands, skills, agents, and permissions, and how to set them up properly.

## Two Folders, Not One

There are actually two `.claude` directories:

- **Project-level** `.claude/` — team configuration, committed to git. Everyone gets the same rules, commands, and permission policies.
- **Global** `~/.claude/` — personal preferences and machine-local state (session history, auto-memory).

## CLAUDE.md: Claude's Instruction Manual

When you start a Claude Code session, the first thing it reads is `CLAUDE.md`. It loads it straight into the system prompt and keeps it in mind for the entire conversation.

You can have:
- `CLAUDE.md` at your project root (most common)
- `~/.claude/CLAUDE.md` for global preferences across all projects
- `CLAUDE.md` inside subdirectories for folder-specific rules

Claude reads all of them and combines them.

### What Belongs in CLAUDE.md

**Write:**
- Build, test, and lint commands
- Key architectural decisions
- Non-obvious gotchas
- Import conventions, naming patterns, error handling styles
- File and folder structure for main modules

**Don't write:**
- Anything that belongs in a linter or formatter config
- Full documentation you can already link to
- Long paragraphs explaining theory

> Keep CLAUDE.md under 200 lines. Files longer than that eat too much context, and Claude's instruction adherence drops.

### Minimal Effective Example

```
# Project: Acme API

## Commands
npm run dev          # Start dev server
npm run test         # Run tests (Jest)
npm run lint         # ESLint + Prettier check
npm run build        # Production build

## Architecture
- Express REST API, Node 20
- PostgreSQL via Prisma ORM
- All handlers live in src/handlers/
- Shared types in src/types/

## Conventions
- Use zod for request validation in every handler
- Return shape is always { data, error }
- Never expose stack traces to the client
- Use the logger module, not console.log

## Watch out for
- Tests use a real local DB, not mocks. Run `npm run db:test:reset` first
- Strict TypeScript: no unused imports, ever
```

### CLAUDE.local.md for Personal Overrides

Create `CLAUDE.local.md` in your project root for preferences specific to you. Claude reads it alongside `CLAUDE.md`, and it's automatically gitignored.

## The rules/ Folder: Modular Instructions That Scale

Every markdown file inside `.claude/rules/` gets loaded alongside `CLAUDE.md` automatically.

```
.claude/rules/
├── code-style.md
├── testing.md
├── api-conventions.md
└── security.md
```

### Path-Scoped Rules

Add YAML frontmatter to a rule file and it only activates when Claude is working with matching files:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/handlers/**/*.ts"
---
# API Design Rules

- All handlers return { data, error } shape
- Use zod for request body validation
- Never expose internal error details to clients
```

Rules without a `paths` field load unconditionally every session.

## The commands/ Folder: Custom Slash Commands

Every markdown file in `.claude/commands/` becomes a slash command:
- `review.md` → `/project:review`
- `fix-issue.md` → `/project:fix-issue`

### Example Command

```markdown
---
description: Review the current branch diff for issues before merging
---
## Changes to Review

!`git diff --name-only main...HEAD`

## Detailed Diff

!`git diff main...HEAD`

Review the above changes for:
1. Code quality issues
2. Security vulnerabilities
3. Missing test coverage
4. Performance concerns

Give specific, actionable feedback per file.
```

The `!` backtick syntax runs shell commands and embeds the output.

### Passing Arguments

Use `$ARGUMENTS` to pass text after the command name:

```markdown
---
description: Investigate and fix a GitHub issue
argument-hint: [issue-number]
---
Look at issue #$ARGUMENTS in this repo.

!`gh issue view $ARGUMENTS`

Understand the bug, trace it to the root cause, fix it, and write a
test that would have caught it.
```

### Personal vs. Project Commands

- Project commands in `.claude/commands/` → committed, shared with team → `/project:command-name`
- Personal commands in `~/.claude/commands/` → available across all projects → `/user:command-name`

## The skills/ Folder: Reusable Workflows on Demand

**Key distinction from commands:** Skills are workflows that Claude can invoke on its own, without you typing a slash command, when the task matches the skill's description. Commands wait for you. Skills watch the conversation and act when the moment is right.

```
.claude/skills/
├── security-review/
│   ├── SKILL.md
│   └── DETAILED_GUIDE.md
└── deploy/
    ├── SKILL.md
    └── templates/
        └── release-notes.md
```

### SKILL.md Structure

```markdown
---
name: security-review
description: Comprehensive security audit. Use when reviewing code for
  vulnerabilities, before deployments, or when the user mentions security.
allowed-tools: Read, Grep, Glob
---
Analyze the codebase for security vulnerabilities:

1. SQL injection and XSS risks
2. Exposed credentials or secrets
3. Insecure configurations
4. Authentication and authorization gaps

Report findings with severity ratings and specific remediation steps.

Reference @DETAILED_GUIDE.md for our security standards.
```

Skills can also be called explicitly with `/security-review`.

**Key difference from commands:** skills can bundle supporting files alongside them. Commands are single files. Skills are packages.

Personal skills go in `~/.claude/skills/` and are available across all projects.

## The agents/ Folder: Specialized Subagent Personas

```
.claude/agents/
├── code-reviewer.md
└── security-auditor.md
```

### Example Agent

```markdown
---
name: code-reviewer
description: Expert code reviewer. Use PROACTIVELY when reviewing PRs,
  checking for bugs, or validating implementations before merging.
model: sonnet
tools: Read, Grep, Glob
---
You are a senior code reviewer with a focus on correctness and maintainability.

When reviewing code:
- Flag bugs, not just style issues
- Suggest specific fixes, not vague improvements
- Check for edge cases and error handling gaps
- Note performance concerns only when they matter at scale
```

When Claude spawns this agent, it works in its own isolated context window, compresses findings, and reports back — without cluttering your main session.

- `tools` field restricts what the agent can do (intentional — a security auditor has no business writing files)
- `model` field lets you use a cheaper, faster model for focused tasks (Haiku for read-only exploration, Sonnet/Opus for complex work)

Personal agents go in `~/.claude/agents/` and are available across all projects.

## settings.json: Permissions and Project Config

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Read",
      "Write",
      "Edit"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)"
    ]
  }
}
```

- **`allow`** — commands that run without asking for confirmation
- **`deny`** — commands blocked entirely, no matter what
- **Neither list** — Claude asks before proceeding (safe middle ground)

### settings.local.json

Same idea as `CLAUDE.local.md`. Create `.claude/settings.local.json` for permission changes you don't want committed. Auto-gitignored.

## The Global ~/.claude/ Folder

- `~/.claude/CLAUDE.md` — loads into every session, across all projects
- `~/.claude/projects/` — session transcripts and auto-memory per project (browsable with `/memory`)
- `~/.claude/commands/` and `~/.claude/skills/` — personal commands/skills across all projects

## The Full Picture

```
your-project/
├── CLAUDE.md                  # Team instructions (committed)
├── CLAUDE.local.md            # Your personal overrides (gitignored)
│
└── .claude/
    ├── settings.json          # Permissions + config (committed)
    ├── settings.local.json    # Personal permission overrides (gitignored)
    │
    ├── commands/              # Custom slash commands
    │   ├── review.md          # → /project:review
    │   ├── fix-issue.md       # → /project:fix-issue
    │   └── deploy.md          # → /project:deploy
    │
    ├── rules/                 # Modular instruction files
    │   ├── code-style.md
    │   ├── testing.md
    │   └── api-conventions.md
    │
    ├── skills/                # Auto-invoked workflows
    │   ├── security-review/
    │   │   └── SKILL.md
    │   └── deploy/
    │       └── SKILL.md
    │
    └── agents/                # Specialized subagent personas
        ├── code-reviewer.md
        └── security-auditor.md

~/.claude/
├── CLAUDE.md                  # Your global instructions
├── settings.json              # Your global settings
├── commands/                  # Your personal commands (all projects)
├── skills/                    # Your personal skills (all projects)
├── agents/                    # Your personal agents (all projects)
└── projects/                  # Session history + auto-memory
```

## A Practical Setup to Get Started

1. Run `/init` inside Claude Code — generates a starter `CLAUDE.md` by reading your project. Edit down to essentials.
2. Add `.claude/settings.json` with allow/deny rules. At minimum: allow run commands, deny `.env` reads.
3. Create one or two commands for your most frequent workflows (code review, issue fixing).
4. As `CLAUDE.md` gets crowded, split instructions into `.claude/rules/` files. Scope by path where it makes sense.
5. Add `~/.claude/CLAUDE.md` with your personal preferences.

## Key Insight

> CLAUDE.md is your highest-leverage file. Get that right first. Everything else is optimization.

The `.claude` folder is a protocol for telling Claude who you are, what your project does, and what rules it should follow. The more clearly you define that, the less time you spend correcting Claude and the more time it spends doing useful work.
