# dot-claude-code

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg" /></a>
  &nbsp;
  <a href="https://claude.com/claude-code"><img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-Powered-d97757?logo=anthropic" /></a>
</p>

Personal Claude Code config — rules, skills, agents, and hooks versioned in git and symlinked into `~/.claude/`.

## Structure

```
global/
├── CLAUDE.md              # Core instructions
├── settings.json          # Permissions, hooks, feature flags
├── statusline-command.sh  # Status line script
├── rules/                 # Auto-loaded topic rules
├── skills/                # Slash command workflows
├── agents/                # Subagent definitions
└── hooks/                 # Pre/PostToolUse shell hooks
templates/
└── skill-template/        # Starter for new skills
```

## Rules

| File | Covers |
|------|--------|
| `git.md` | Conventional commit format |
| `working-approach.md` | Validate before reporting done |
| `verify-before-assume.md` | Verify external facts before using them |

## Skills

| Skill | Command | What it does |
|-------|---------|--------------|
| `grill-me` | `/grill-me` | Relentless interview to stress-test a plan |
| `claude-md-audit` | `/claude-md-audit` | Audit and rewrite CLAUDE.md files |
| `skill-creator` | `/skill-creator` | Create and audit skills with quality scoring |

## Agents

Subagent definitions for focused autonomous tasks:

| Agent | Trigger | What it does |
|-------|---------|--------------|
| `code-reviewer` | on demand | Reviews code for bugs and quality |
| `debugger` | on demand | Systematic root-cause debugging |
| `docs-updater` | Mon–Fri 03h | Audits and fixes README/CLAUDE.md gaps |
| `pipeline-health` | Mon–Fri 04h | Detects failing, flaky, and slow CI workflows |
| `security-scanner` | Mon–Fri 05h + PR | Scans for secrets, SAST issues, IaC misconfigs |
| `dependency-watchdog` | Mondays 01h | Updates deps, fixes CVEs, opens PRs |
| `daily-briefing` | Mon–Fri 06h | Compiles overnight agent findings into a digest |

> Cron agents are definitions only — scheduling requires GitHub Actions workflows.

## Hooks

- **PreToolUse** `rtk-rewrite.sh` — rewrites Bash commands through RTK for token savings
- **PostToolUse** `bash-fail-guard.sh` — catches failure patterns after Bash runs
- **PostToolUse** (inline) — `bash -n` on `.sh` edits, `jq empty` on `.json` edits

## Install

```bash
git clone https://github.com/mateusoliveirab/dot-claude-code.git
cd dot-claude-code
```

Then use `/link-config` inside Claude Code to symlink individual items into `~/.claude/`. Items are linked individually — your existing setup is never overwritten wholesale.

## Env vars

Copy `.env.example` and set:

```bash
CLAUDE_CODE_NEW_INIT=1
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1   # experimental: multi-agent teams
```

## Validate

```bash
jq empty global/settings.json
python global/skills/skill-creator/scripts/audit_skill.py global/skills/<name>
```

## License

MIT
