# Output Patterns Reference

How to define what a skill produces. The pattern you choose determines how much control you have over the output format vs. how much freedom Claude has to adapt.

## Pattern Types

| Pattern | Control | Best For |
|---------|---------|----------|
| Template | Exact structure | APIs, commits, PRs, config files |
| Examples | Style/quality calibration | Writing, reviews, naming |
| Hybrid | Structure + calibrated tone | Complex multi-section outputs |

---

## Template Pattern

Use when the output **must** follow an exact structure. Fragile consumers (parsers, CI, APIs) require this.

**How to implement:** Provide the literal template with placeholders and the directive "ALWAYS use this exact template."

### Good Template

```markdown
## Output Format

ALWAYS use this exact template:

\```json
{
  "endpoint": "{METHOD} {path}",
  "description": "{one-line summary}",
  "parameters": [
    { "name": "{param}", "type": "{type}", "required": {true|false} }
  ],
  "response": "{description of response shape}"
}
\```
```

### Bad Template

```markdown
## Output Format

Generate JSON documentation for the API endpoint. Include the method,
path, description, parameters, and response info.
```

The bad version gives no structure -- Claude will invent a different shape every time.

---

## Examples Pattern

Use when **style and quality** matter more than exact structure. Input/output pairs teach by demonstration rather than description.

**How to implement:** Provide 3-5 input/output pairs that show the transformation you want.

### Good Examples

```markdown
## Examples

Input: "Added user auth"
Output: "feat(auth): implement JWT-based user authentication"

Input: "fix bug with login"
Output: "fix(auth): resolve session expiry on idle timeout"

Input: "updated readme"
Output: "docs: update installation steps for Docker setup"
```

### Bad Alternative (prose instead of examples)

```markdown
## Style Guide

Write commit messages using conventional commits. Be specific.
Use imperative mood. Keep it under 72 characters.
```

The prose version is ambiguous -- "be specific" means different things to different people. Examples **show** the exact calibration you want.

---

## Hybrid Pattern

Combine template (for structure) with examples (for tone calibration within sections).

### Example: Code Review Skill

```markdown
## Output Format

ALWAYS use this structure:

### Summary
{1-2 sentence overall assessment}

### Issues Found
- **[severity]** {file}:{line} - {description}

### Suggestions
- {actionable improvement}

## Tone Calibration

Example summary (good):
"Clean implementation. Two potential null-pointer issues in the auth
module need attention before merge."

Example summary (bad):
"LGTM!" (too shallow)
"This code has numerous problems..." (too vague)
```

---

## Degrees of Freedom Guide

How tightly to constrain Claude's output based on the task type.

| Freedom | When to Use | Implementation | Example |
|---------|-------------|----------------|---------|
| **LOW** | Exact sequences, fragile consumers | Exact templates, numbered steps | Commit messages, API docs, config generation |
| **MEDIUM** | Preferred patterns with room for judgment | Templates + adaptation notes | Code reviews, PR descriptions |
| **HIGH** | Investigation, creative, exploratory | Textual guidance, multiple valid paths | Debugging, architecture analysis, brainstorming |

### Low Freedom -- Implementation

```markdown
ALWAYS follow these steps in order:
1. Read the input file
2. Extract all function signatures
3. Generate output using the EXACT template below
4. Validate output matches the schema

Output MUST match this template:
\```
...
\```
```

### Medium Freedom -- Implementation

```markdown
Use this structure as a baseline:
\```
...
\```

Adapt the depth based on:
- Small changes (< 20 lines): brief summary only
- Medium changes (20-100 lines): summary + key details
- Large changes (> 100 lines): full breakdown with section headers
```

### High Freedom -- Implementation

```markdown
Investigate the issue using these approaches (in any order):
- Check error logs for stack traces
- Inspect recent commits for regressions
- Review related test failures

Report findings in whatever format best communicates the root cause.
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Prose-only output spec | Inconsistent results across runs | Add a concrete template or examples |
| Template without context | Claude follows structure but misses intent | Add 2-3 examples showing desired quality |
| Too many degrees of freedom on structured tasks | Output varies wildly | Reduce to LOW freedom with exact template |
| Too few degrees of freedom on exploratory tasks | Rigid output misses nuance | Increase to HIGH freedom with guidance |

---

## Quick Decision Checklist

1. Will a machine parse this output? --> **Template (LOW freedom)**
2. Will a human read this for quality? --> **Examples (MEDIUM freedom)**
3. Is the output exploratory/diagnostic? --> **Guidance (HIGH freedom)**
4. Both structured AND quality-sensitive? --> **Hybrid**
