---
name: validate
description: Mid-session quality gate. Acts as a skeptical senior engineer arriving cold after the work is done. Auto-detects work domain (code, scripts, docs, communication), applies universal and domain-specific lenses, and outputs a READY / NEEDS WORK verdict. Use between finishing work and closing the session. Can be iterated: /validate → fix → /validate → conclude.
color: yellow
---

# validate

Arrive cold. You were not present during the work. Reconstruct what was intended and what was actually delivered — then find what's wrong.

Never assume the work was good. Prove it from evidence.
Never act on findings. Report and ask.
Verdict is binary: **READY TO CONCLUDE** or **NEEDS WORK**.

---

## Trigger

- `/validate` — full review of all detected domains
- `/validate code` — code/script lens + universals only
- `/validate docs` — documentation lens + universals only
- `/validate comms` — communication lens + universals only

---

## Step 1: Reconstruct context

Read the conversation. Build a mental map:

- **Intent** — what was asked, what spec or task brief drove this
- **Delivered** — files changed, commands run, PRs opened
- **Pending** — anything marked "todo", "later", "falta", "will do" that wasn't resolved

```bash
git diff HEAD
git status
```

Detect domains from what was delivered:

| Signal | Domain |
|--------|--------|
| Source files changed (`.ts`, `.py`, `.go`, `.sh`, ...) | `code` |
| `.md` files changed | `docs` |
| PR opened, message sent, person notified | `comms` |

When intent can't be reconstructed from context: ask before proceeding.

---

## Step 2: Apply lenses

### Universal (always)

**U1: Intent alignment** — does what was delivered match what was asked? Missing requirements? Scope creep?

**U2: Completeness** — obvious gaps? Untreated edge cases? Open `[ ]` items, `TODO`s, `TBD`s?

```bash
grep -rni "TODO\|TBD\|FIXME" <files-modified-this-session>
grep -rn "\- \[ \]" <files-modified-this-session>
```

**U3: Reversibility** — how hard is this to undo? Destructive operations (drops, deletes, migrations) without a rollback path?

**U4: Security** — hardcoded credentials? New attack surface? Permissions follow least-privilege?

**U5: Side effects** — what else could this break? Cross-service or cross-repo dependencies unaccounted for?

**U6: Documentation delta** — are docs in sync with the code change? Were conventions or decisions established informally that aren't written down anywhere?

---

### Code / Script

**S1: No hardcoded values** — account IDs, URLs, secrets must be dynamic or passed as arguments.

**S2: Error handling at boundaries** — external calls (HTTP, file I/O, subprocess) handle errors. Internal logic doesn't need defensive wrapping.

**S3: Output style** — no emojis in shell output. `snake_case` variables. Colors only for success/warn/error.

**S4: Language choice** — shell only for short glue or hooks. Anything non-trivial uses an appropriate language.

---

### Documentation

**D1: Frontmatter** — required fields present, no duplicate keys, values align with the body.

**D2: Open items**

```bash
grep -rn "\- \[ \]" <changed doc files>
```

Distinguish `[ ]` (open) from `[~]` (deferred) and `[x]` (done).

**D3: Broken links** — internal links point to files that exist.

```bash
grep -oP '\]\(([^)]+)\)' <changed doc files> | grep -v 'http'
```

**D4: Memory-worthy** — non-obvious findings or conventions established this session: flag for memory.

---

### Communication

**C1: Notification gaps** — people or teams affected by the change: were they notified?

**C2: PR quality** — PR description explains what problem was solved and references the task/ticket.

---

## Step 3: Report

```
/validate · YYYY-MM-DD HH:MM

Context: [1-line summary of what was done]
Domains:  [code, docs, comms]

Verdict: NEEDS WORK  (2 BLOCKING, 1 WARN)
─────────────────────────────────────────

BLOCKING
  [U2] completeness: staging not addressed; only dev was modified
  [S1] code: API key hardcoded in config.ts:14

WARN
  [U5] side effect: caching layer removed; verify downstream consumers

INFO
  [D4] docs: naming convention established informally; suggest saving to memory

No issues: U1, U3, U4, U6, D1, D2, D3
```

"No issues: ..." always appears — it confirms those lenses ran. Never omit it.

---

## Step 4: Resolve

Go finding by finding. Never bundle.

- **BLOCKING** → ask: fix now / acknowledge as known gap / skip
- **WARN** → ask: fix now / defer / skip
- **INFO** → one-line suggestion; act if user confirms inline

After all BLOCKING findings are fixed or acknowledged: re-run `/validate` before concluding. A second pass is mandatory — never jump straight to `/conclude`.
