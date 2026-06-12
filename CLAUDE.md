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

Each skill: `global/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description` required). References and scripts are optional subdirs loaded on demand.

Progressive disclosure: only frontmatter loads at startup (~50 tokens). Full SKILL.md loads on activation.

### Skill Audit

`audit_skill.py` scores 7 categories. Score ≥ 80 is production-ready.

## Code Style

**Bash:** `#!/usr/bin/env bash` + `set -euo pipefail`
**Markdown:** YAML frontmatter between `---`, `kebab-case.md` filenames
**JSON:** 2-space indent, no trailing commas

## Testing Checklist

`jq empty global/settings.json` passes, no secrets committed, `.env.example` updated if new env vars added.

## Git

`git` CLI only. Conventional commits. Branch prefixes: `feat/`, `fix/`, `chore/`, `docs/`.
