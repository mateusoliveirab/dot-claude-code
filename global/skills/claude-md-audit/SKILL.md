---
name: claude-md-audit
description: Audits and rewrites CLAUDE.md files. Use when the user asks to review, optimize, rewrite, standardize, or improve a CLAUDE.md file. Triggers include "audit claude.md", "otimiza o claude.md", "melhora o claude.md", "padroniza claude.md", "review CLAUDE.md".
---

# claude-md-audit

Audit and rewrite the project's CLAUDE.md so every line earns its place.

## Philosophy (from community consensus + Karpathy 2026)

- **Each line must be earned** — if removing it wouldn't cause Claude to make a mistake, cut it.
- **< 150 lines ideal, 200 hard cap** — bloated files get ignored.
- **Advisory, not enforcement** — CLAUDE.md is ~70% followed. Put deterministic rules in hooks, not here.
- **No documentation** — CLAUDE.md is not a README. Assume Claude can read the code.

## Sections (use only what applies)

### Required
**Stack** — one line listing framework · language · key libs with versions. No bullets.

**Gotchas** — non-obvious constraints Claude would get wrong without being told. Format: `**Title** — explanation + example if needed`. Only things not derivable from code.

### Conditional (include if relevant)
**Architecture** — only if the routing/access model is non-standard or split across personas/roles.

**Conventions** — naming, file size limits, theming tokens, language (i18n). Only rules Claude would violate without explicit guidance.

**Environment Variables** — only if Claude needs to know which vars exist and what they do. Skip obvious ones.

**Commands** — only non-obvious commands. Skip `npm run dev` if it's standard. Include gotchas like "server already running".

### Never include
- What the project does (Claude reads the code)
- Generic best practices Claude already knows
- Anything duplicated from code, config, or package.json
- Comments like "This file provides guidance to Claude Code..."
- Conventional Commits explanation (Claude knows this)

## Format rules

Use this compact format throughout:

```
**Short title** — detailed explanation with references, examples, and constraints as needed. One paragraph max.
```

For tables (auth models, key splits): use markdown tables, keep them small.

For code snippets: only include when the correct pattern is non-obvious or easy to get wrong.

## Audit process

1. **Read** the current CLAUDE.md
2. **For each item, ask:**
   - Would Claude make a mistake without this? → Keep
   - Is this derivable from reading the code? → Cut
   - Is this a generic best practice? → Cut
   - Is this duplicated elsewhere (README, config)? → Cut
   - Is this too verbose? → Compress to one line
3. **Restructure** into the sections above, using `**Title** — description` format
4. **Check length** — aim for < 100 lines. Flag if > 150.
5. **Identify @imports** — if any section is large and module-specific, suggest moving to a subdir CLAUDE.md or `.claude/rules/` file with `@` import.

## Output

Rewrite the full CLAUDE.md inline. Do not show a diff or ask for confirmation — apply directly and report:
- Lines removed (and why)
- Lines compressed
- Sections restructured
- Anything suggested for @import extraction
