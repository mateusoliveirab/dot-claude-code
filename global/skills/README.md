# Skills Directory

This directory contains reusable Agent Skills following the [Agent Skills specification](https://agentskills.io/specification).

## How Skills Work

Skills use **progressive disclosure** to manage context efficiently:

### 1. Discovery (Startup)

At startup, Claude loads only the `name` and `description` from each skill's frontmatter (~50-100 tokens per skill). This keeps initial context usage low while making skills available for activation.

Example:
```yaml
---
name: git-commit
description: Streamlined git commit workflow with best practices...
---
```

### 2. Activation (Task Match)

When your request matches a skill's description, Claude automatically activates it by loading the full `SKILL.md` instructions. Skills are triggered by keywords in your request.

**Examples of activation:**
- "Commit these changes" → Activates `git-commit`
- "Create a PR" → Activates `git-pr`
- "/git-commit" → Directly invokes the skill

### 3. Execution (On Demand)

Once activated, Claude follows the skill's workflow:
- Executes scripts from `scripts/` directory
- Reads reference documentation from `references/`
- Uses templates from `assets/`

Resources are loaded only when needed, keeping context usage efficient.

## Available Skills

| Skill | Description | Command |
|-------|-------------|---------|
| `git-commit` | Streamlined git commit workflow with validation | `/git-commit` |
| `git-pr` | Prepare pull request content and analysis | `/git-pr` |

## Using Skills

### Direct Invocation

Type the skill name with a leading slash:
```
/git-commit
/git-pr main
```

### Natural Language

Mention the skill's purpose in your request:
```
"Help me commit these changes"
"I need to create a pull request"
"Validate my commit message"
```

### From Scripts

Reference skill scripts directly:
```bash
# Validate commit
bash global/skills/git-commit/scripts/validate-commit.sh --check-sensitive

# Analyze PR
bash global/skills/git-pr/scripts/analyze-pr.sh main
```

## Skill Structure

Each skill follows this structure:

```
skill-name/
├── SKILL.md              # Required: Instructions and metadata
├── scripts/              # Executable helpers
│   └── helper.sh
├── references/           # Documentation
│   └── REFERENCE.md
└── assets/              # Templates and resources
    └── TEMPLATE.md
```

### SKILL.md Format

Must include YAML frontmatter:

```yaml
---
name: skill-name
description: When to use this skill - include keywords for matching
auto_invoke: false
compatibility: Optional - required tools, packages
metadata:
  author: Your name
  version: "1.0"
---
```

**Field descriptions:**
- `name` (required): Skill identifier, lowercase with hyphens
- `description` (required): When to use, 10-1024 characters
- `auto_invoke`: Whether to auto-activate (usually false)
- `compatibility`: Required tools or environment
- `metadata`: Arbitrary key-value pairs (author, version, etc.)

## Security

Scripts in this directory:
- Validate all inputs before execution
- Support `--dry-run` for previewing changes
- Never execute destructive operations without confirmation
- Log all actions for auditing

**Best practices:**
1. Always review scripts before first use
2. Use `--help` to understand script options
3. Test with `--dry-run` when available
4. Never run scripts with sudo unless explicitly required

## Validation

Validate all skills before committing:

```bash
# Validate all skills
bash scripts/validate-all-skills.sh

# Generate XML for agent prompts
bash scripts/validate-all-skills.sh --xml

# Validate specific directory
bash scripts/validate-all-skills.sh /path/to/skills
```

## Creating New Skills

1. Copy the template:
   ```bash
   cp -r templates/skill-template global/skills/my-skill
   ```

2. Update SKILL.md with your workflow

3. Add scripts to `scripts/` (make them executable)

4. Add references to `references/`

5. Validate:
   ```bash
   bash scripts/validate-all-skills.sh
   ```

6. Install to ~/.claude/:
   ```bash
   bash install.sh
   ```

## Progressive Disclosure Guidelines

Keep skills efficient:

1. **SKILL.md**: Under 500 lines (ideally <100)
2. **References**: Move detailed docs to `references/`
3. **Scripts**: Self-contained with clear dependencies
4. **Assets**: Templates with usage instructions

This ensures fast loading while maintaining rich functionality.

## Reference

- [Agent Skills Specification](https://agentskills.io/specification)
- [Integration Guide](https://agentskills.io/integrate-skills)
- [Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Template](../templates/skill-template/) - Starting point for new skills
