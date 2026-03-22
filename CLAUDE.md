# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A dotfiles-style repository for Claude Code global configuration (`~/.claude/`). Modular rules, reusable skills, MCP server configs, and permissions — versioned in git for easy sync across machines. No package manager or test suite; pure bash + optional Python stdlib.

## Commands

```bash
# Install (copies global/ to ~/.claude/)
bash install.sh

# Dry-run install (no changes)
bash install.sh --dry-run

# Audit a specific skill with scoring
python global/skills/skill-creator/scripts/audit_skill.py global/skills/<skill-name>

# Syntax check install script
bash -n install.sh

# Validate JSON configs
jq empty global/settings.json
jq empty global/mcp.json
```

## Architecture

### Directory Layout

- `global/` — Everything installed to `~/.claude/`
  - `CLAUDE.md` — Minimal base instructions
  - `settings.json` — Permissions and preferences
  - `mcp.json` — MCP server configs (chrome-devtools, shadcn-ui, supabase)
  - `rules/` — Topic-specific rule files (auto-loaded by Claude Code)
  - `skills/` — Reusable `/command` workflows (git-commit, git-pr, skill-creator, opencode-task-splitter)
  - `agents/` — Subagent definitions
- `templates/` — Starter templates for project CLAUDE.md and new skills
- `scripts/` — Validation and utility scripts
- `docs/` — Design docs and feature plans

### Skill Structure

Each skill lives in `global/skills/<skill-name>/` with:
- `SKILL.md` — Main definition with YAML frontmatter (name, description required)
- `references/` — On-demand detail docs (loaded only when skill activates)
- `scripts/` — Helper bash/python scripts
- `assets/` — Templates and static content

**Progressive disclosure design:** Skills load only name + description (~50-100 tokens) at startup. Full SKILL.md loads on activation. References load on-demand. SKILL.md should stay under 500 lines (ideal: 100-200).

### Skill Frontmatter Spec

```yaml
---
name: kebab-case-name        # required, max 64 chars
description: What + WHEN     # required, max 1024 chars
---
```

`auto_invoke`, `trigger`, `keywords`, `tags` are **invalid fields** — the audit script flags them.

### Skill Audit Scoring

`audit_skill.py` scores 7 categories: frontmatter (15%), documentation (20%), workflow (20%), examples (15%), structure (15%), scripts (10%), cross-model compat (5%). Score >= 80 is production-ready. All 5 critical gates must score >= 60.

### Install Script

Uses `rsync` (fallback `cp --parents`), backs up existing configs, merges MCP configs via `jq` + `envsubst`. All bash scripts use `set -euo pipefail` and support `--dry-run`.

## Code Style

### Bash
- Shebang: `#!/usr/bin/env bash` with `set -euo pipefail`
- Functions: `snake_case()`, UPPERCASE for constants, lowercase for locals
- Quote all variables, use `||` fallbacks, errors to stderr

### Markdown
- YAML frontmatter between `---` markers for rules/skills
- Files: `kebab-case.md`, soft wrap at 100 chars

### JSON
- 2-space indent, no trailing commas

## Testing Checklist

Before submitting: `bash -n install.sh` passes, `bash install.sh --dry-run` succeeds, JSON files validate with `jq empty`, no secrets in committed files, `.env.example` updated if new env vars added.

## Git

Use `git` CLI (not `gh`). Follow conventional commit style. Use `/git-commit` and `/git-pr` skills.
Branch naming: `feat/`, `fix/`, `chore/`, `docs/` prefixes matching the commit type.
