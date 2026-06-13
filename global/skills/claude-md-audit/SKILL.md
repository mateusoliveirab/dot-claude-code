---
name: claude-md-audit
description: Audits and rewrites CLAUDE.md files. Use when the user asks to review, optimize, rewrite, standardize, or improve a CLAUDE.md file. Triggers include "audit claude.md", "otimiza o claude.md", "melhora o claude.md", "padroniza claude.md", "review CLAUDE.md". Also use when someone says "clean up my docs", "my claude context is messy", or asks to "initialize" context files in a project.
---

# claude-md-audit

Audit and rewrite CLAUDE.md files so every line earns its place.

Every line must justify its existence: if removing it wouldn't cause Claude to make a mistake, cut it. Files over 200 lines get ignored — that's not a soft guideline, it's how context works. Deterministic rules (always X, never Y) belong in hooks, not here — CLAUDE.md is followed ~70% of the time. Claude reads the code; don't describe what the project does.

---

## Scope

If the user points to a specific file, audit that file. If they point to a directory (or give no path), scan the tree:

```bash
find <root> -name "CLAUDE.md" ! -path '*/.git/*' ! -path '*/node_modules/*' | sort
```

In tree mode, classify by depth: `root` (0), `tier` (1), `project` (2+). Each level has a different job — root is navigation and global conventions, tier is a scope statement and content table, project is status, resume commands, and key files.

---

## Cut unconditionally

- Self-referential openers ("This file provides guidance to Claude Code...")
- Project description / what the project does
- Generic best practices Claude already knows (DRY, error handling, test coverage)
- Conventional Commits explanation
- Content duplicated from package.json, go.mod, config files, or README
- Deterministic always/never rules → suggest moving to hooks

---

## What belongs (use only what applies)

**Stack** — one line: framework · language · key libs with versions.

**Gotchas** — non-obvious constraints Claude would get wrong without being told. Format: `**Title** — explanation`. Only things not derivable from reading the code.

**Architecture** — only if routing or access model is non-standard.

**Conventions** — naming, file size limits, language. Only rules Claude would violate without explicit guidance.

**Environment Variables** — only if Claude needs to know which vars exist. Skip obvious ones.

**Commands** — only non-obvious commands. Include gotchas like "server already running".

---

## Duplication checks

- Repeats content already in a parent CLAUDE.md?
- Repeats content already in `~/.claude/CLAUDE.md` or `~/.claude/rules/`?
- Prose paragraphs where a table row would suffice?
- Bullet lists with 3+ nesting levels where a flat table would work?

---

## Process

**Analyze first.** For each file, count lines (`wc -l`) and run the checklists above. Produce a verdict: `ok`, `needs-rewrite`, or `needs-creation`. Files over 200 lines are `needs-rewrite` unconditionally. Files between 150–200 lines get flagged for compression even if individual items seem valid.

**Show findings before writing anything:**

```
CLAUDE.md Audit: <root>

Files found: N  (needs-rewrite: N · ok: N · needs-creation: N)

[needs-rewrite] <path>  (N lines)
  - <issue>

[ok] <path>
  ✓ No changes needed

[needs-creation] <path>/CLAUDE.md
  - <reason>
```

Then ask:
```
Proceed? all · select · preview · cancel
```

If exactly 1 file needs rewriting: `1 file flagged. [enter] to apply · p to preview · c to cancel`

**Execute only after confirmation.** Read the current content immediately before writing. Report what was removed and why.

---

## Format convention

Use this pattern throughout:

```
**Short title** — explanation with context or example. One paragraph max.
```

Tables for lookup data. Code blocks only when the correct pattern is non-obvious. No prose paragraphs. No 3-level bullet nests.
