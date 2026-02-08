# dot-claude-code-installation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Last Commit](https://img.shields.io/github/last-commit/mateusoliveirab/dot-claude-code-installation)](https://github.com/mateusoliveirab/dot-claude-code-installation/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/mateusoliveirab/dot-claude-code-installation)](https://github.com/mateusoliveirab/dot-claude-code-installation)
[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Development-007ACC?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Powered-d97757?logo=anthropic)](https://claude.com/claude-code)
[![opencode](https://img.shields.io/badge/opencode-Powered-22c55e)](https://opencode.ai)
[![Git](https://img.shields.io/badge/Git-Control-f05032?logo=git&logoColor=white)](https://git-scm.com/)

My personal Claude Code setup — modular rules, reusable skills, MCP servers, and sane defaults. Versioned with git and easy to install.

The idea is simple: instead of one giant CLAUDE.md file, split instructions into focused rules that Claude loads automatically. Keep everything in git so you can track changes and sync across machines.

If you already have a `~/.claude/CLAUDE.md`, don't worry — the install script preserves it. You can gradually migrate content to rules or keep using both.

## What's Included

### Core Instructions (`global/CLAUDE.md`)
Base instructions that apply to every conversation — communication style, working approach, MCP usage.

### Modular Rules (`global/rules/`)
Topic-specific guidelines loaded automatically:

| Rule | What it covers |
|------|----------------|
| `communication.md` | How I like to communicate, when to ask vs do |
| `working-approach.md` | Task execution, fast mode usage |
| `dev-workflow.md` | Git workflow, commit preferences |
| `mcp-usage.md` | MCP shortcuts and guidelines |
| `auto-memory.md` | When to update MEMORY.md |

### Skills (`global/skills/`)
Reusable workflows invoked with `/command`:

| Skill | Command | What it does |
|-------|---------|--------------|
| `git-commit` | `/git-commit` | Conventional commits, groups by functionality |
| `git-pr` | `/git-pr` | Generate PR content (I open manually to review) |

### Settings (`global/settings.json`)
- Thinking mode always on (use `/fast` for quick tasks)
- Granular permissions — auto-approve safe operations, block dangerous ones
- No prompt suggestions (cleaner experience)

### MCP Servers (`global/mcp.json`)
Pre-configured servers:
- **Chrome DevTools** — UI validation
- **Shadcn UI** — Component lookup
- **Supabase** — DB operations (needs `SUPABASE_ACCESS_TOKEN`)

## Quick Start

```bash
git clone https://github.com/mateusoliveirab/dot-claude-code-installation.git
cd dot-claude-code-installation

# Optional: set up env vars for MCPs
cp .env.example .env
# edit .env with your tokens

bash install.sh
```

The script installs everything to `~/.claude/` and backs up existing configs. Restart Claude Code after install.

**Needs:** `jq` for MCP merging (`sudo apt install jq` or `brew install jq`)

## Customizing

Add your own rules in `~/.claude/rules/`. Use frontmatter for control:

```markdown
---
description: React conventions
paths: ["src/components/**/*"]
---

- Use TypeScript
- Prefer function components
```

Create new skills by copying `templates/skill-template/`. Check `global/skills/` for examples.

Edit `~/.claude/settings.json` to tweak permissions.

## Structure

```
dot-claude-code-installation/
├── install.sh              # One-command install
├── global/
│   ├── CLAUDE.md          # Core instructions
│   ├── settings.json      # Permissions & preferences
│   ├── mcp.json          # MCP server configs
│   ├── skills/           # Reusable workflows
│   │   ├── git-commit/
│   │   └── git-pr/
│   └── rules/            # Topic-specific rules
└── templates/
    └── skill-template/   # Copy this for new skills
```

## Why This Approach?

- **Modular** — Rules by topic instead of one huge file
- **Versioned** — Track changes per rule in git
- **Reusable** — Skills work across projects
- **Safe** — Granular permissions, fewer prompts for routine stuff

## Contributing

This setup started as my personal configuration, but contributions are welcome. Whether you have ideas for new skills, improvements to existing rules, or better documentation, your feedback is always appreciated.

To contribute:
- **New Skills**: Add reusable workflows that others might find useful
- **Rule Improvements**: Enhance existing guidelines or add new topic-specific rules
- **Documentation**: Help improve clarity or add examples
- **Bug Fixes**: Fix issues you encounter while using the setup

Feel free to open an issue to discuss ideas or submit a pull request with your changes.

## License

MIT — feel free to use, modify, and distribute as needed.
