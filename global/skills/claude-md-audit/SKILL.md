---
name: claude-md-audit
description: Audits and rewrites CLAUDE.md files. Use when the user asks to review, optimize, rewrite, standardize, or improve a CLAUDE.md file. Triggers include "audit claude.md", "otimiza o claude.md", "melhora o claude.md", "padroniza claude.md", "review CLAUDE.md". Also use when someone says "clean up my docs", "my claude context is messy", or asks to "initialize" context files in a project.
---

# claude-md-audit

Audit and rewrite CLAUDE.md files so every line earns its place. Works on a single file or a full directory tree.

## Philosophy

- **Each line must be earned** — if removing it wouldn't cause Claude to make a mistake, cut it.
- **< 150 lines ideal, 200 hard cap** — files above this threshold dilute context and get ignored.
- **Advisory, not enforcement** — CLAUDE.md is followed ~70% of the time. Deterministic rules (always X, never Y) belong in hooks or settings.json, not here.
- **Not a README** — assume Claude reads the code and knows the framework.

## Scope detection

**Single file**: if the user points to a specific CLAUDE.md, audit that file only.

**Tree mode**: if the user points to a directory (or no path is given), scan for all CLAUDE.md files:

```bash
find <root> -name "CLAUDE.md" ! -path '*/.git/*' ! -path '*/node_modules/*' | sort
```

In tree mode, classify each file by depth from root:

| Tier | Depth | Role |
|------|-------|------|
| `root` | 0 | Navigation + global conventions |
| `tier` | 1 | Scope statement + content table for that subtree |
| `project` | 2+ | Project-specific: status, resume commands, key files |

## Never include (cut unconditionally)

- Self-referential openers ("This file provides guidance to Claude Code...")
- Project description / what the project does (Claude reads the code)
- Generic best practices Claude already knows (DRY, error handling, test coverage)
- Conventional Commits explanation
- Content duplicated from package.json, go.mod, config files, or README
- Deterministic always/never rules with no caveats → suggest moving to hooks for 100% compliance

## Sections (use only what applies)

**Stack** — one line: framework · language · key libs with versions. No bullets.

**Gotchas** — non-obvious constraints Claude would get wrong without being told. Format: `**Title** — explanation + example`. Only things not derivable from code.

**Architecture** — only if routing/access model is non-standard or split across roles.

**Conventions** — naming, file size limits, theming tokens, language. Only rules Claude would violate without explicit guidance.

**Environment Variables** — only if Claude needs to know which vars exist and what they do. Skip obvious ones.

**Commands** — only non-obvious commands. Include gotchas like "server already running".

## Duplication checks

- Repeats content already in a parent CLAUDE.md?
- Repeats content already in `~/.claude/CLAUDE.md` or `~/.claude/rules/`?
- Prose paragraphs where a table row would suffice?
- Bullet lists with 3+ nesting levels where a flat table would work?

## Audit process

### Phase 1: Analyze

For each file, produce a structured finding:
- **Lines** (count via `wc -l`)
- **Issues found** (list from checklists above)
- **Verdict**: `ok` | `needs-rewrite` | `needs-creation`

Line count rules:
- > 200 lines → `needs-rewrite` unconditionally
- 150–200 lines → flag for compression even if individual items seem valid

### Phase 2: Propose (write gate)

Print an audit summary before writing anything:

```
CLAUDE.md Audit: <root>

Files found: N
  needs-rewrite: N
  ok: N
  needs-creation: N

FINDINGS:

[needs-rewrite] <path>  (<N> lines)
  - <issue>

[ok] <path>
  ✓ No changes needed

[needs-creation] <path>/CLAUDE.md
  - <reason>
```

Then ask:
```
Proceed? Options:
  all     : rewrite flagged files + create missing files
  select  : choose which files to act on
  preview : show draft for one file without writing
  cancel  : stop here
```

**Single-file shortcut:** if exactly 1 file needs rewriting, collapse to:
```
1 file flagged. [enter] to apply · p to preview · c to cancel
```

Do not write anything until the user responds.

### Phase 3: Execute

For each confirmed file:

1. Read current content immediately before writing.
2. Apply rewrites: cut what fails the checklists, compress verbose items, restructure into the sections above.
3. Write the new content.
4. Report: lines removed (and why), lines compressed, sections restructured.

## Format convention

Use this compact format throughout:

```
**Short title** — explanation with context or example if needed. One paragraph max.
```

Use tables for lookup data (stacks, modules, environments, routes).
Use code blocks only when the correct pattern is non-obvious or easy to get wrong.
Avoid prose paragraphs and 3-level bullet nests.
