---
name: conclude
description: Pre-close session review. Scans for loose ends before ending a conversation — documentation gaps, unsaved memory, open checklist items, uncommitted git changes, and notification gaps. Reports findings grouped by category; never acts without confirmation. Invoke at the end of any work session before signing off.
color: green
---

# conclude

Scan for loose ends before closing the session. Report findings. Never act without confirmation.

If nothing is found: print `All clear. Session closed.` and stop.

---

## Step 1: Read the session

Scan the conversation for:

- Files created or modified
- Tasks or tickets mentioned or worked on
- People or teams affected by changes
- Anything explicitly deferred, delegated, or left pending

Only run checks that have surface area in this session. Skip the rest.

---

## Step 2: Checks

### D: Documentation

**D1: Frontmatter** — for each file with `---` block: required fields present, no duplicate keys, values match the body.

**D2: Parent index** — if a new file or directory was created, does the parent CLAUDE.md reference it?

**D3: Open checklist items**

```bash
grep -rn "\- \[ \]" <files-modified-this-session>
```

`[ ]` = open, `[~]` = deferred, `[x]` = done. Flag open ones.

**D4: Runbook gap** — if a non-obvious problem was resolved: are there notes on what to do when it recurs?

**D5: Context-to-persistence gap** — scan for things that exist only in this conversation and were never written down:
- Decisions made ("we'll use X", "decided Y")
- Naming conventions or patterns established mid-session
- Hypotheses ruled out that would waste time to re-investigate
- Command outputs that revealed useful facts
- Delegations to other people

Flag anything with no corresponding record outside the conversation. Ask if unsure whether it was already persisted elsewhere.

---

### M: Memory

**M1: Unsaved insights** — non-obvious solutions, new conventions, corrections to previous assumptions found this session but not in MEMORY.md. Ask before saving.

**M2: Stale memory** — if a finding this session contradicts an existing memory entry, flag it for update or removal.

---

### G: Git

**G1: Uncommitted changes**

```bash
git status
```

Flag modified or untracked files in repos touched this session. Ask if it's unclear whether to commit now.

---

### N: Notifications

**N1: Notification gap** — people or teams affected by changes who weren't notified. Ask if unsure whether notification already happened outside the conversation.

---

## Step 3: Report

```
## conclude · session review [YYYY-MM-DD]

| # | Category | Status | Finding |
|---|----------|--------|---------|
| D3 | Documentation | open | README.md: 1 unchecked item: "[ ] Update env vars" |
| M1 | Memory | open | New convention established (resolved- prefix): not yet saved |
| G1 | Git | open | rules/git.md: uncommitted changes |
| N1 | Notifications | clean | Team already notified via PR comment |
```

Status: `open` (needs action) · `clean` (nothing to do) · **`FIXED`** (resolved during this session)

Closing line:
- All clean → `All clear. Session closed.`
- Open items → `Session review complete. X item(s) require attention.`

---

## Step 4: Resolve

Go finding by finding. For clear fixes: propose in one line, execute after inline confirm. For judgment calls: ask with specific options. Never batch.

Confirm `Session closed.` after all findings are resolved.
