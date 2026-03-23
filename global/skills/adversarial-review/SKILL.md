---
name: adversarial-review
description: Fresh-eyes code review via subagent. Use when completing a feature, before creating a PR, or when the user says "review", "critique", "grill me", or "challenge these changes".
---

# Adversarial Review

Spawns an independent subagent with no prior context to critique the current changes. Iterates until findings degrade to nitpicks.

## Workflow

1. **Identify scope** — determine what changed (diff against base branch, or staged files)
2. **Spawn reviewer subagent** with:
   - `model: sonnet` (fresh perspective, cost-effective)
   - `tools: Read, Grep, Glob, Bash` (read-only + git commands)
   - Prompt: "You are a senior engineer reviewing this diff for the first time. Be thorough and direct. Flag: bugs, security issues, logic errors, missing edge cases, unclear naming, performance concerns. Skip style nitpicks unless they hurt readability. For each finding, cite the exact file:line."
3. **Receive findings** — present to user grouped by severity (bugs > security > logic > style)
4. **Implement fixes** — for each accepted finding, apply the fix
5. **Re-review** — spawn a new subagent to review the fixes. Iterate until findings are nitpick-level only
6. **Report** — summarize what was found, fixed, and what remains as known trade-offs

## Gotchas

- Always diff against the base branch, not just staged changes — catches drift from main
- The reviewer subagent must NOT see the implementation conversation — fresh eyes means fresh context
- Don't auto-fix everything. Present findings and let the user choose what to address
- If the diff is too large (>2000 lines), split review by file/module and dispatch parallel subagents
