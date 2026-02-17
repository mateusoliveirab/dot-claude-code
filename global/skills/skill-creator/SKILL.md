---
name: skill-creator
description: Creates new Agent Skills with proper structure, YAML frontmatter, and best practices. Use when building a new skill, scaffolding skill directories, or converting repeated workflows into reusable skills.
license: MIT
metadata:
  author: User
  version: "2.0.0"
---

# Skill Creator

Creates well-structured Agent Skills following the official specification and best practices.

## Usage

```
/skill-creator [skill-name] [--scope personal|project]
```

Default scope: `personal` (~/.claude/skills/)

## When to Create a Skill

Create a skill when you identify:
- **Repeated workflows** you explain more than twice
- **Domain knowledge** Claude lacks (schemas, APIs, conventions)
- **Multi-step processes** needing consistency across sessions
- **Team patterns** that should be shared and standardized

Do NOT create a skill for:
- One-off tasks
- Generic knowledge Claude already has
- Simple aliases (use shell scripts instead)

## Workflow

Track progress through these steps:

```
- [ ] Step 1: Identify the knowledge gap
- [ ] Step 2: Plan structure and content
- [ ] Step 3: Initialize directory structure
- [ ] Step 4: Write YAML frontmatter
- [ ] Step 5: Write SKILL.md body (draft)
- [ ] Step 6: Validate frontmatter
- [ ] Step 7: Refine body (feedback loop)
- [ ] Step 8: Create references and scripts (if needed)
- [ ] Step 9: Test with fresh context
- [ ] Step 10: Run audit and address suggestions
```

After creating or modifying a skill, ALWAYS run the audit and share results with the user:

```bash
python scripts/audit_skill.py path/to/skill-directory
```

Address any CRITICAL gate failures before considering the skill complete.

**Detailed instructions for each step**: See [references/step-by-step-guide.md](references/step-by-step-guide.md)

### Quick Summary

- **Steps 1-2**: Identify gap + plan structure (HIGH freedom)
- **Steps 3-4**: Init directory + YAML frontmatter (LOW freedom — strict validation)
- **Steps 5-7**: Write body, validate, refine (MEDIUM freedom — follow patterns, adapt to domain)
- **Steps 8-9**: References/scripts if needed + test with fresh context

### Directory Structure (LOW freedom)

```
skill-name/
├── SKILL.md              # Required: core instructions (<500 lines, aim 100-200)
├── references/            # Detailed docs, loaded on-demand (ONE level deep)
├── scripts/               # Executable helpers
└── assets/                # Templates, samples
```

### YAML Frontmatter (LOW freedom)

```yaml
---
name: skill-name           # lowercase, hyphens, max 64 chars
description: What + WHEN.  # max 1024 chars, no angle brackets
---
```

**Invalid fields**: `auto_invoke`, `auto-invoke`, `trigger`, `keywords`, `tags`.
**Naming**: prefer gerund form (`processing-pdfs`, `analyzing-data`). Avoid `helper`, `utils`.

## Key Principles

1. **Context window is a public good** — every token competes with conversation history
2. **Trust agent intelligence** — add only what Claude does not know
3. **SKILL.md under 500 lines** — detailed info in references/
4. **Feedback loops** — validate immediately, fix before continuing
5. **Degrees of freedom** — explicit LOW/MED/HIGH per section
6. **Test across models** — what works for Opus may confuse Haiku
7. **One level deep** — no multi-hop reference chains
8. **Iterate from real usage** — observe agent behavior, then refine

## Anti-patterns

- Explaining what Claude already knows (what is a PR, how git works)
- Using `auto_invoke` or other invalid frontmatter fields
- Deeply nested references (SKILL.md -> a.md -> b.md -> c.md)
- Time-sensitive information ("before August 2025, use...")
- Offering too many options without a clear default
- Vague descriptions ("helps with stuff")

## Auditing Existing Skills

Score any skill directory against the spec:

```bash
python scripts/audit_skill.py path/to/skill-directory
```

| Score | Grade | Action |
|-------|-------|--------|
| 80-100 | Production ready | Deploy as-is |
| 60-79 | Needs improvement | Address suggestions |
| < 60 | Requires refactor | Significant rework |

All critical gates (frontmatter, documentation, workflow, examples, structure) must score >= 60.

## References

- **Step-by-step guide**: See [references/step-by-step-guide.md](references/step-by-step-guide.md)
- **Examples**: See [references/examples.md](references/examples.md)
- **Output patterns**: See [references/output-patterns.md](references/output-patterns.md)
- **Workflow patterns**: See [references/workflows.md](references/workflows.md)
