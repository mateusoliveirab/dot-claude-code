# Templates

This directory contains templates for creating new content in the dot-claude-code-installation repository.

## Available Templates

### 1. Project CLAUDE.md (`CLAUDE.md.example`)

Template for creating project-level `CLAUDE.md` files in new repositories.

**Use when**: Starting a new project and want consistent Claude instructions.

**Location**: Copy to project root as `CLAUDE.md` or `.claude/CLAUDE.md`

**Sections**:
- Project description
- Technology stack
- Conventions and code rules
- Important context and lessons learned

### 2. Skill Template (`skill-template/`)

Complete template for creating new skills following the [Agent Skills specification](https://agentskills.io/specification).

**Use when**: Creating a new reusable skill for Claude Code.

**Location**: Copy to `global/skills/<skill-name>/`

**Structure**:
```
skill-template/
├── README.md              # How to use this template
├── SKILL.md              # Required - skill definition with frontmatter
├── scripts/              # Executable helpers
│   ├── helper.sh         # Example script
│   └── README.md         # Scripts documentation
├── references/           # Additional documentation
│   ├── REFERENCE.md      # Technical reference
│   └── EXAMPLES.md       # Usage examples
└── assets/              # Static resources
    └── TEMPLATE.md      # Example template
```

## Quick Start

### Creating a Project CLAUDE.md

```bash
# Copy template
cp templates/CLAUDE.md.example my-project/CLAUDE.md

# Edit with project details
# nano my-project/CLAUDE.md
```

### Creating a New Skill

```bash
# Copy skill template
cp -r templates/skill-template global/skills/my-skill

# Edit SKILL.md frontmatter
cd global/skills/my-skill
# nano SKILL.md

# Customize scripts
# nano scripts/helper.sh

# Add references
# nano references/REFERENCE.md
```

## Template Guidelines

### For CLAUDE.md

- Replace all `[PROJECT NAME]` placeholders
- Fill in all sections (remove unused ones)
- Be specific about conventions and rules
- Document lessons learned as you go

### For Skills

- **Name**: lowercase with hyphens (e.g., `code-review`, `deploy-app`)
- **Description**: Include keywords agents need to identify the skill
- **Frontmatter**: Required YAML between `---` markers
- **Scripts**: Must be executable (`chmod +x`)
- **References**: Keep focused, load on demand
- **Assets**: Templates should have clear usage instructions

## Validation

### Validate Skill Structure

```bash
# Check directory structure
ls -la global/skills/my-skill/

# Verify SKILL.md has frontmatter
grep -A 5 "^---$" global/skills/my-skill/SKILL.md

# Test scripts
bash -n global/skills/my-skill/scripts/*.sh
```

## Examples

See working examples in `global/skills/`:

- `git-commit/` - Git commit workflow
- `git-pr/` - Pull request preparation

Both follow the template structure and demonstrate best practices.
