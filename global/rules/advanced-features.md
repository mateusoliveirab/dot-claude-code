---
description: Advanced Claude Code features reference — checkpointing, output styles, path-scoped rules, skill variables
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

Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` to enable multi-session coordination. Use subagents for most cases — agent teams are for genuinely independent parallel sessions that need to communicate.
