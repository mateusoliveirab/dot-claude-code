# CLAUDE.md

Claude Code global config repo — rules, skills, agents, and hooks versioned for sync across machines.

## Commands

```bash
# Audit a skill
python global/skills/skill-creator/scripts/audit_skill.py global/skills/<skill-name>

# Validate JSON
jq empty global/settings.json
```

Use `/link-config` to symlink `global/` items into `~/.claude/`.

## Architecture

- `global/` — installed to `~/.claude/`: `CLAUDE.md`, `settings.json`, `rules/`, `skills/`, `agents/`, `hooks/`
- `templates/` — starters for new projects and skills
- `docs/` — reference documentation

### Skills

Each skill: `global/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description` required). References and scripts are optional subdirs.

`audit_skill.py` scores 7 categories — score ≥ 80 is production-ready.

## Code Style

**Bash:** `#!/usr/bin/env bash` + `set -euo pipefail`
**Markdown:** YAML frontmatter between `---`, `kebab-case.md` filenames
**JSON:** 2-space indent, no trailing commas

## Docs Sync

Docs and code drift easily here. After any change, update every related doc in the same commit — `README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, and relevant files under `docs/`. Adding/removing a skill, agent, hook, script, or settings key means updating wherever it's listed. A `Docs Updater` GitHub workflow (opencode) is a backstop, not a substitute — keep docs current as you go.

## Testing Checklist

`jq empty global/settings.json` passes, no secrets committed, `.env.example` updated if new env vars added.

## Git

`git` CLI only. Conventional commits. Branch prefixes: `feat/`, `fix/`, `chore/`, `docs/`.
