# dot-claude-code

Personal Claude Code setup — global instructions, modular rules, skills, MCP servers, and granular permissions, versioned with an install script.

## Philosophy

This setup combines:
- **`CLAUDE.md`** — Core global instructions (always loaded)
- **`rules/*.md`** — Modular topic-specific rules (also loaded automatically)

Rules expand on the base instructions and allow organizing guidelines by topic. Both are loaded by Claude Code.

## Components

### Global Instructions (`global/CLAUDE.md`)

Core instructions that apply to all conversations:
- Communication guidelines
- Working approach
- Dev workflow preferences
- MCP server usage

### Modular Rules (`global/rules/`)

Topic-specific instruction files loaded automatically by Claude Code:

| Rule | Purpose |
|---|---|
| `communication.md` | Communication guidelines, clarification rules |
| `working-approach.md` | Task execution approach, fast mode usage |
| `dev-workflow.md` | Development workflow, git preferences |
| `mcp-usage.md` | MCP server usage guidelines and shortcuts |
| `auto-memory.md` | Auto-learning and memory management |

**Key benefit**: Claude loads all rules automatically, but you can organize them logically and extend with topic-specific rules as needed.

### Skills (`global/skills/`)

Reusable workflows invoked with `/skill-name`:

| Skill | Command | Purpose |
|---|---|---|
| `git-commit` | `/git-commit` | Streamlined git commit workflow with best practices |
| `git-pr` | `/git-pr` | Prepare pull request content (git CLI, not gh CLI) |

Skills can include supporting files (templates, examples, scripts) in their directories.

### Settings (`global/settings.json`)

| Setting | Value | Description |
|---|---|---|
| `alwaysThinkingEnabled` | `true` | Thinking mode always on (use `/fast` for simple tasks) |
| `promptSuggestionEnabled` | `false` | Prompt suggestions disabled |
| `permissions.alwaysAllow` | Array | Auto-approve safe operations (Read, Grep, Glob, common git/lint commands) |
| `permissions.alwaysDeny` | Array | Block dangerous operations (force delete, force push, writing to .env files) |

**Key benefit**: Fewer permission prompts for routine operations, strong protection for dangerous actions.

### MCP Servers (`global/mcp.json`)

| Server | Usage |
|---|---|
| **Chrome DevTools** | Validate UI changes, inspect elements, verify layout |
| **Shadcn UI** | Add/lookup shadcn/ui components |
| **Supabase** | Database operations, authentication and storage |

### Extensibility

| Directory | Purpose | Status |
|---|---|---|
| `global/agents/` | Custom subagent definitions | Available (empty) |
| `global/skills/` | Reusable skills and workflows | 2 skills included |
| `global/rules/` | Modular topic-specific rules | 5 rules included |

### Project Template (`templates/CLAUDE.md.example`)

Base template for creating `CLAUDE.md` in new projects with sections for stack, conventions and code rules.

## Installation

```bash
git clone <repo-url> && cd dot-claude-code
bash install.sh
```

The script will:
1. Create `~/.claude/` if it doesn't exist
2. Back up the previous setup to `~/.claude/backup-YYYYMMDD-HHMMSS/`
3. Install `settings.json` and `mcp.json`
4. Copy `agents/`, `skills/` and `rules/` directories to `~/.claude/`
5. Show available skills and summary

**Note**: `CLAUDE.md` is deprecated in this setup. If you have an existing one, it will be preserved but not overwritten. Consider migrating to modular rules in `~/.claude/rules/`.

Restart Claude Code after installation.

## Customization

### Adding Rules

Create new `.md` files in `~/.claude/rules/`:

```bash
# Example: Frontend-specific rules
~/.claude/rules/frontend/react.md
~/.claude/rules/frontend/tailwind.md

# Example: Backend-specific rules
~/.claude/rules/backend/api.md
~/.claude/rules/backend/database.md
```

Rules support frontmatter for advanced control:

```markdown
---
description: React component conventions
paths: ["src/components/**/*", "app/components/**/*"]
---

# React Rules

- Always use TypeScript
- Prefer function components over class components
...
```

### Adding Skills

Create skill directories in `~/.claude/skills/`:

```bash
~/.claude/skills/my-skill/
├── SKILL.md           # Required - main instructions
├── template.md        # Optional - templates for Claude to fill in
├── examples/
│   └── sample.md      # Optional - example outputs
└── scripts/
    └── helper.py      # Optional - utility scripts
```

### Modifying Permissions

Edit `~/.claude/settings.json`:

```json
{
  "permissions": {
    "alwaysAllow": [
      { "tool": "Read", "pathPattern": "your-dir/**/*" }
    ],
    "alwaysDeny": [
      { "tool": "Bash", "prompt": "dangerous operation" }
    ]
  }
}
```

### Project-Level Customization

Both global (`~/.claude/`) and project-level (`.claude/`) configurations are supported. Project-level settings override global ones.

## Structure

```
dot-claude-code/
├── README.md
├── install.sh
├── .gitignore
├── global/
│   ├── settings.json         # Claude Code settings with granular permissions
│   ├── mcp.json              # MCP server configuration
│   ├── agents/               # Custom subagent definitions (empty, planned)
│   ├── skills/               # Reusable skills (git-commit, git-pr)
│   │   ├── git-commit/
│   │   │   └── SKILL.md
│   │   └── git-pr/
│   │       └── SKILL.md
│   └── rules/                # Modular topic-specific rules
│       ├── communication.md
│       ├── working-approach.md
│       ├── dev-workflow.md
│       ├── mcp-usage.md
│       └── auto-memory.md
└── templates/
    └── CLAUDE.md.example     # Template for new projects
```

## Benefits Over Monolithic CLAUDE.md

1. **Better organization**: Rules grouped by topic
2. **Easier maintenance**: Edit individual rule files
3. **Extensibility**: Add new rules without touching existing ones
4. **Selective loading**: Future support for path-based rule filtering
5. **Version control**: Easier to track changes per topic
6. **Reusability**: Skills provide powerful workflows beyond simple instructions
7. **Efficiency**: Fewer permission prompts with granular permissions

## Migration from CLAUDE.md

If you have an existing `~/.claude/CLAUDE.md`:

1. The install script preserves it (doesn't overwrite)
2. Both `CLAUDE.md` and `rules/*.md` will be loaded
3. Consider migrating content from `CLAUDE.md` to appropriate rule files
4. Once migrated, you can remove `CLAUDE.md`

## Available Skills

After installation, invoke these skills with:

- `/git-commit` — Streamlined commit workflow with best practices
- `/git-pr [target-branch]` — Prepare PR content for GitHub (uses git CLI)
