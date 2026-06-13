---
source: claude-workbench
name: skill-refine
description: >
  Captures high-value learnings from a skill execution and applies targeted improvements
  to the SKILL.md. Generic: works for any skill. Invoke right after running a skill when
  steps diverged from the documented flow, new techniques were discovered, or undocumented
  edge cases appeared. Synthesizes from conversation context automatically.
---

# skill-refine

Refines a skill's SKILL.md based on execution learnings from the current session.
Reads the skill file, synthesizes what diverged, proposes surgical edits, applies them,
and syncs to the workbench mirror.

**Only works with same-session context.** The skill being refined must have been executed
in the current conversation.

## Inputs

| Input | Default | Notes |
|-------|---------|-------|
| `skill-name` | inferred from context | Skill directory name, e.g. `coralogix-add-user` |

If `skill-name` is not passed as argument, identify the most recently executed skill from
the conversation. If ambiguous, use AskUserQuestion to confirm.

## Paths

| File | Path |
|------|------|
| Live skill | `~/.claude/skills/{name}/SKILL.md` |
| Mirror | `~/repos/claude-workbench/config/dot-claude/skills/{name}/SKILL.md` |

Always update both. Use `cp` to sync the mirror: do not use the Write tool on the mirror file.

## Execution

### Phase 0: Load

1. Resolve the skill name (argument or conversation inference).
2. If unclear, use AskUserQuestion: "Confirming: refining `{name}`, correct?"
3. Read `~/.claude/skills/{name}/SKILL.md`.
4. Confirm to the user: "Analyzing execution context for `/{name}`..."

### Phase 1: Synthesize learnings

Scan the conversation for high-value learnings: things that will improve assertiveness
on the next execution. Focus on:

- **Flow divergences**: steps documented one way but that required a different approach in practice
- **Reliable techniques**: specific commands, JS patterns, tool sequences that worked when others failed
- **Undocumented edge cases**: situations that occurred but aren't covered by the existing Edge cases section
- **Failure modes**: steps that failed, why, and what the fix was

Filter ruthlessly: only capture learnings that are non-obvious, not already implied by
the current SKILL.md, and likely to recur. Do not add learnings that restate existing content.

Use AskUserQuestion if a learning is ambiguous or you need to confirm intent before adding.

### Phase 2: Propose edits

For each learning:
1. Identify the target location in the SKILL.md:
   - Execution flow step → update that specific step inline
   - New edge case → add to Edge cases section (create the section if it doesn't exist)
   - New technical pattern → add inline within the relevant step or in a dedicated block
     (e.g., "Browser automation notes") for UI-heavy skills
2. Draft the edit using the same formatting conventions as the existing file (tables, code blocks, bullet style).
3. Present a concise before/after to the user.

**Surgical edits only.** Do not rewrite sections that don't need changing.
Do not alter frontmatter, section titles, or overall formatting conventions.

**Structural refactors (new FORMAT.md split, section reorder, compression):** before applying, verify all behavioral rules survive the change. Check explicitly:
1. Priority/ordering rules (e.g., "DPE > PLAT > KairosLIST")
2. Negative constraints ("never", "always", "do not", "cap at")
3. Output shape rules (format, grouping, numbering)
4. Decision tree logic (if/when conditions)

None of these are derivable from structure — they must be explicitly present in the new version.

Confirm with the user before applying.

### Phase 3: Apply + sync

1. Apply all confirmed edits with the Edit tool at `~/.claude/skills/{name}/SKILL.md`.
2. No cp needed — `~/.claude/skills/` entries are symlinks into the workbench mirror. Editing the live path already updates the canonical file. Verify with `readlink ~/.claude/skills/{name}` if unsure.
3. Remind the user: "Run `/commit` to version the changes."

## Principles

- Surgical edits, not rewrites: preserve what works
- Only add learnings that would meaningfully change how a future execution unfolds
- Learnings belong where they'll be read: inline in the execution step, Edge cases section,
  or a dedicated block for UI-heavy or browser automation skills
- Never duplicate: if the learning is already implied by existing text, skip it
- If a needed section doesn't exist (Edge cases, etc.), create it rather than cramming
  content into an ill-fitting location

## Example invocations

```
/skill-refine coralogix-add-user
/skill-refine jira
/skill-refine
```
