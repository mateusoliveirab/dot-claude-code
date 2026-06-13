---
name: conclude
description: Pre-close session review. Scans for loose ends before ending a conversation — documentation gaps, unsaved memory, open checklist items, uncommitted git changes, and notification gaps. Reports findings grouped by category; never acts without confirmation. Invoke at the end of any work session before signing off.
color: green
---

# conclude: Pre-Close Session Review

Reviews the current conversation and file system state to ensure nothing was left
incomplete before closing the session.

## Trigger

- `/conclude`: run full review and report

---

## Behavior contract

- Never act on findings automatically: only report and ask
- Use **AskUserQuestion** whenever intent is ambiguous before surfacing an assumption as a finding
- Keep the report short: one line per finding, grouped by category
- If nothing is found: print `All clear. Session closed.` and stop

---

## When to use AskUserQuestion

| Situation | Example question |
|-----------|-----------------|
| File edited but unclear if it should be committed | "There are uncommitted changes in rules/. Should I stage them?" |
| Open checklist item — unclear if deferred or forgotten | "README.md has an unchecked item '[ ] Update env vars'. Was this intentionally deferred?" |
| Memory-worthy insight not yet saved | "I noticed a recurring pattern with X. Should I save this to memory for future sessions?" |
| Unclear if someone was already notified | "This change may affect [team/person]. Were they already notified?" |

Do NOT use AskUserQuestion for clear-cut findings (broken link, duplicate frontmatter field, confirmed open item). Report those directly.

---

## Phase 0: Context scan

Read the current conversation and identify:

- Files created or modified this session
- Tasks or tickets mentioned or worked on
- People or teams affected by changes made
- Actions explicitly marked as "pending", "in progress", or delegated to someone else

---

## Phase 1: Checks

Run only checks with surface area from Phase 0. Skip checks with no activity in this session.

### D: Documentation

**D1: Frontmatter completeness**
For each file with a `---` block created or modified this session:
- Required fields present? (name/title, status, date if applicable)
- Duplicate keys?
- Values align with document body?

**D2: Parent index updated**
If a new file or directory was created: does the parent CLAUDE.md or index reference it?

**D3: Open checklist items**
```bash
grep -rn "\- \[ \]" <files-modified-this-session>
```
Distinguish `[ ]` (open) from `[~]` (deferred) and `[x]` (done).

**D4: Runbook gap**
If an incident or non-obvious problem was resolved: are there notes documenting what to do when it recurs?

**D5: Context-to-persistence gap**
Review the conversation for anything that exists only here and was NOT persisted to a file or memory entry:
- Decisions made ("let's use X", "we decided Y")
- Conventions or naming patterns established mid-conversation
- Command outputs that revealed useful facts
- Hypotheses ruled out worth recording so they are not re-investigated next time
- Agreements or delegations to other people

Flag anything with no corresponding record outside the conversation.

---

### M: Memory

**M1: Unsaved memory-worthy insights**
From Phase 0, identify:
- Non-obvious solutions discovered this session
- Recurring patterns not yet documented
- New conventions established (naming, formatting, workflow)
- Corrections made to previous assumptions

If found and not yet in MEMORY.md: use AskUserQuestion to confirm before saving.

**M2: Stale memory contradicted by this session**
If a finding this session contradicts an existing memory entry: flag for update or removal.

---

### G: Git

**G1: Uncommitted changes**
```bash
git status
```
Flag any modified or untracked files in repos touched this session.
Use AskUserQuestion if changes are present and it's unclear whether to commit now.

---

### N: Notifications

**N1: Notification gap**
From Phase 0: were there people or teams affected by changes who were not notified?

---

## Phase 2: Report

```
## conclude · session review [YYYY-MM-DD]

| # | Category | Status | Finding |
|---|----------|--------|---------|
| D3 | Documentation | open | README.md: 1 unchecked item: "[ ] Update env vars" |
| M1 | Memory | open | New convention established (resolved- prefix): not yet saved |
| G1 | Git | open | rules/git.md: uncommitted changes |
| N1 | Notifications | clean | Team already notified via PR comment |
```

**Status values:**
- `open` — needs action, confirm before proceeding
- `clean` — nothing to do
- **`FIXED`** — resolved during this session (shown for completeness)

If all categories are clean: print `> All clear. Session closed.` and stop.

Closing line:
- All clean: `> All clear. Session closed.`
- Open items remain: `> Session review complete. X item(s) require attention.`

---

## Phase 3: Resolution

After printing the report, address each open finding:

1. For findings with an obvious fix and no ambiguity: propose the fix in one line, execute after user confirms inline
2. For findings requiring judgment: use AskUserQuestion with specific options
3. Never batch all fixes into a single prompt — go finding by finding
4. After all findings resolved: confirm `Session closed.`

---

## Scope controls

- Only check files/repos actually touched in this session
- Never modify files automatically without confirmation
- Skip `.git/`, `node_modules/`, `.terraform/` in all searches
- Do not re-run checks already resolved earlier in the same conversation
