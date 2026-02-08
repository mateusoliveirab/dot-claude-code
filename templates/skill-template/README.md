# Skill Template

This is a complete template for creating new skills following the Agent Skills specification.

## Quick Start

1. Copy this directory:
   ```bash
   cp -r templates/skill-template global/skills/my-skill
   ```

2. Update the frontmatter in `SKILL.md`:
   ```yaml
   ---
   name: my-skill
   description: What this skill does and when to use it
   auto_invoke: false
   ---
   ```

3. Customize the content:
   - Edit `SKILL.md` with your workflow
   - Update `scripts/helper.sh` with your logic
   - Add reference docs to `references/`
   - Add templates to `assets/`

4. Test and install

## File Structure

```
skill-name/
├── SKILL.md              # Required - main instructions
├── scripts/              # Executable helpers
│   └── helper.sh
├── references/           # Additional documentation
│   └── REFERENCE.md
└── assets/              # Static resources
    └── TEMPLATE.md
```

## Naming Conventions

- **Skill name**: lowercase with hyphens (e.g., `git-commit`, `code-review`)
- **Scripts**: descriptive names (e.g., `validate.sh`, `analyze.py`)
- **References**: UPPERCASE (e.g., `COMMANDS.md`, `API_REFERENCE.md`)
- **Assets**: descriptive (e.g., `PR_TEMPLATE.md`, `config-template.json`)

## Best Practices

1. **Keep SKILL.md under 500 lines** - Move detailed content to references/
2. **Scripts should be self-contained** - Document dependencies clearly
3. **Use progressive disclosure** - SKILL.md first, references on demand
4. **Include examples** - Show inputs/outputs in references/
5. **Handle edge cases** - Document error scenarios

## Validation

Before using, validate your skill:
- Check frontmatter format (YAML between `---`)
- Verify name matches directory name
- Ensure scripts are executable (`chmod +x`)
- Test all file references work

## Example Skills

See `global/skills/git-commit/` and `global/skills/git-pr/` for working examples.
