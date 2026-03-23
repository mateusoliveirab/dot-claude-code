---
name: skill-name
description: Brief description of what this skill does and when to use it. Include specific keywords that help agents identify relevant tasks.
---

# Skill Name

Brief overview of what this skill accomplishes. This appears when the skill is activated.

## Usage

```
/skill-name [optional-arguments]
```

## Workflow

1. **Check prerequisites**: Verify requirements are met
2. **Gather information**: Collect necessary data
3. **Execute task**: Perform the main operation
4. **Validate results**: Confirm success

Reference detailed guides when needed:
- [references/REFERENCE.md](references/REFERENCE.md) - Technical details
- [references/EXAMPLES.md](references/EXAMPLES.md) - Usage examples

## Scripts

Run helper scripts for complex operations:

```bash
# Basic usage
scripts/helper.sh

# With options
scripts/helper.sh --option value
```

See script help for details: `scripts/helper.sh --help`

## Assets

Use templates from [assets/](assets/) directory:
- `assets/TEMPLATE.md` - Starting template
- `assets/config-template.json` - Configuration example

## Gotchas

> The highest-signal content in any skill. Build this up from real failure modes over time.

- **Gotcha 1**: Description of a non-obvious failure mode and how to avoid it
- **Gotcha 2**: Description of another common pitfall

## Safety Considerations

- Never run destructive commands without confirmation
- Validate all inputs before processing
- Check for sensitive data in outputs
- Use dry-run mode when available

## Reference

See [references/REFERENCE.md](references/REFERENCE.md) for:
- Detailed technical information
- Command reference
- Configuration options
- Troubleshooting guide
