# Step-by-Step Guide

Detailed instructions for each step of the skill creation workflow.

---

## Step 1: Identify the Knowledge Gap

Ask yourself:
- What does Claude get wrong or miss without this skill?
- What information do I repeatedly provide?
- What would a domain expert know that Claude does not?

**Degree of freedom: HIGH** -- multiple valid approaches to scoping.

## Step 2: Plan Structure

Decide what goes where:

```
skill-name/
├── SKILL.md              # Required: core instructions (<500 lines)
├── references/            # Detailed docs, loaded on-demand
│   └── REFERENCE.md
├── scripts/               # Executable helpers
│   └── helper.sh
└── assets/                # Templates, samples
    └── TEMPLATE.md
```

Rules:
- SKILL.md is the entry point -- keep it concise
- References must be ONE level deep (no multi-hop navigation)
- Every file must justify its token cost

**Degree of freedom: MEDIUM** -- standard structure, flexible organization within it.

## Step 3: Initialize Directory

```bash
SKILL_NAME="my-skill"
SCOPE="personal"  # or "project"

if [ "$SCOPE" = "personal" ]; then
  BASE_DIR="$HOME/.claude/skills/$SKILL_NAME"
else
  BASE_DIR=".claude/skills/$SKILL_NAME"
fi

mkdir -p "$BASE_DIR"/{references,scripts,assets}
touch "$BASE_DIR/SKILL.md"
```

**Degree of freedom: LOW** -- exact directory structure required.

## Step 4: Write YAML Frontmatter

**Degree of freedom: LOW** -- strict validation rules, no flexibility.

ALWAYS use this exact structure:

```yaml
---
name: skill-name
description: What this skill does and WHEN to use it. Include trigger keywords for discovery.
---
```

**Validation rules (enforced by quick_validate.py):**

| Field | Required | Rules |
|-------|----------|-------|
| `name` | Yes | Max 64 chars, lowercase, numbers, hyphens only. No reserved words (anthropic, claude). |
| `description` | Yes | Max 1024 chars. No angle brackets. Must describe WHAT + WHEN. Third person voice. |
| `license` | No | License identifier |
| `allowed-tools` | No | Tool permissions |
| `metadata` | No | Arbitrary key-value pairs |
| `compatibility` | No | Max 500 chars. Required tools/environment. |

**Invalid fields** (will fail validation): `auto_invoke`, `auto-invoke`, `trigger`, `keywords`, `tags`.

**Naming convention** -- prefer gerund form:
- `processing-pdfs`, `analyzing-data`, `managing-deploys`
- Acceptable: `pdf-processor`, `data-analyzer`
- Avoid: `helper`, `utils`, `tools`

## Step 5: Write SKILL.md Body (Draft)

**Degree of freedom: MEDIUM** -- follow patterns below, adapt content to domain.

Core principle: **Context window is a public good.** Every token must justify itself.

Body structure (adapt as needed):

```markdown
# Skill Name

One-line description of what this skill does.

## Usage
How to invoke the skill.

## Workflow
Step-by-step process with checklist.

## Format / Output
Expected output structure (template or examples pattern).

## Key Rules
Domain-specific constraints Claude must follow.

## References
Links to reference files for detailed information.
```

**Writing guidelines:**
- Under 500 lines total (YAML + body). Aim for 100-200 lines.
- Use checklists for multi-step workflows
- Include feedback loops for quality-critical steps
- Provide 1-3 input/output examples
- Explicit degrees of freedom (LOW/MED/HIGH) per section
- No time-sensitive information
- Consistent terminology throughout

## Step 6: Validate Frontmatter

Run validation immediately after writing frontmatter:

```bash
python scripts/quick_validate.py path/to/SKILL.md
```

**Feedback loop:** If validation fails, fix and re-validate before proceeding. Do NOT continue with invalid frontmatter.

## Step 7: Refine Body (Feedback Loop)

Review the draft against this checklist:

```
Body Quality Check:
- [ ] Does each paragraph justify its token cost?
- [ ] Can I assume Claude already knows this? (remove if yes)
- [ ] Are workflows using checklists?
- [ ] Are there feedback loops for critical operations?
- [ ] Are degrees of freedom explicit?
- [ ] Are examples concrete (input/output pairs)?
- [ ] Is terminology consistent?
- [ ] Is the file under 500 lines?
- [ ] Are references one level deep?
```

If any item fails: fix, then re-check. Iterate until all pass.

**Cut aggressively.** If the first draft is 300+ lines, aim to cut 40-60%.

## Step 8: Create References and Scripts

Move detailed content to reference files when SKILL.md exceeds ~200 lines or when content serves a distinct purpose.

**References** (loaded on-demand by Claude):
```markdown
**Advanced configuration**: See [references/CONFIG.md](references/CONFIG.md)
**API reference**: See [references/API.md](references/API.md)
```

**Scripts** (executed, not loaded into context):
```bash
#!/usr/bin/env bash
set -e

if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is required. Install with: apt install jq"
  exit 1
fi
```

Script rules:
- Solve problems, do not punt to Claude
- Explicit error handling with actionable messages
- Document all hardcoded values
- Forward slashes for all paths

## Step 9: Test with Fresh Context

Test the skill in a new Claude session (no prior context):

1. Start fresh conversation
2. Invoke the skill naturally or with `/skill-name`
3. Observe: Does Claude find the right information?
4. Check: Does it follow the workflow correctly?
5. Note: Where does it struggle or deviate?

**Test across models if possible:**
- Haiku: Does it provide enough guidance?
- Sonnet: Is it clear and efficient?
- Opus: Does it avoid over-explaining?

Common fixes:
- Agent explores unexpected paths -> reorganize references
- Agent misses connections -> make links more prominent
- Agent over-reads a section -> split or move to reference
- Agent ignores content -> remove or rewrite description
