---
name: skill-refine
description: Captures high-value learnings from a skill execution and applies targeted improvements to the SKILL.md. Generic: works for any skill. Invoke right after running a skill when steps diverged from the documented flow, new techniques were discovered, or undocumented edge cases appeared. Synthesizes from conversation context automatically.
upstream: https://github.com/mateusborges-kto/claude-workbench · config/dot-claude/skills/skill-refine/SKILL.md
# To validate: compare with the source repo above
---

# skill-refine

Refine a skill's SKILL.md based on what actually happened this session. Only works with same-session context — the skill must have been executed in the current conversation.

## Resolve the skill

If the skill name is not passed as an argument, infer it from the most recently executed skill in the conversation. If ambiguous, ask: "Confirming: refining `{name}`, correct?"

Read `~/.claude/skills/{name}/SKILL.md`. Since these are symlinks into the dot-claude-code repo, editing the live path updates the canonical file — verify with `readlink ~/.claude/skills/{name}` if unsure.

## Synthesize learnings

Scan the conversation for what diverged or was discovered. Focus on:

- **Flow divergences** — steps documented one way but that required a different approach in practice
- **Reliable techniques** — specific commands, patterns, or tool sequences that worked when others failed
- **Undocumented edge cases** — situations that occurred but aren't covered by the current SKILL.md
- **Failure modes** — steps that failed, why, and what the fix was

Filter ruthlessly. Only capture learnings that are non-obvious, not already implied by existing text, and likely to recur. If a learning is ambiguous, ask before adding it.

## Propose edits

For each learning, identify where it belongs:
- Flow divergence → update that step inline
- New edge case → add to an Edge cases section (create it if it doesn't exist)
- New technical pattern → add inline within the relevant step

Show a concise before/after for each change. Confirm with the user before applying.

**Surgical edits only.** Don't rewrite sections that don't need changing. Don't touch frontmatter, section titles, or formatting conventions unless the learning requires it.

If doing a structural refactor, verify explicitly that these survive: priority/ordering rules, negative constraints (never/always/do not), output shape rules, and decision tree logic. None of these are derivable from structure — they must be explicitly present in the new version.

## Apply

Apply confirmed edits with the Edit tool at `~/.claude/skills/{name}/SKILL.md`. Then: "Run `/commit` to version the changes."
