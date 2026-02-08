---
name: skill-name
description: Brief description of what this skill does and when to use it. Include specific keywords that help agents identify relevant tasks.
auto_invoke: false
compatibility: Optional - required tools, packages, or environment (e.g., "Requires git, node")
metadata:
  author: your-name
  version: "1.0.0"
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

## Edge Cases

- **Empty input**: Handle gracefully with clear error message
- **Network unavailable**: Cache results or provide fallback
- **Large datasets**: Process in batches

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
