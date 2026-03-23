---
name: freeze
description: Restrict all file edits to a specific directory for the current session. Use when debugging, when the user says "freeze", "only edit in X", or "don't touch anything outside X". Prevents accidental changes to unrelated code.
---

# Freeze Mode

Restricts all Write/Edit operations to a specified directory for the session duration. Behavioral enforcement — you check each file path before editing.

## Usage

```
/freeze src/api/
/freeze .
```

## Workflow

1. **Accept target directory** — the user specifies which directory is writable. Default: current working directory
2. **Announce** — "Freeze mode: edits restricted to `<directory>`. All other paths are read-only."
3. **Enforce** — before any Write or Edit tool call, verify the target path is within the frozen directory. If not, refuse and explain
4. **Unfreeze** — "unfreeze" or "remove freeze" disables the restriction

## Gotchas

- Behavioral enforcement only — relies on the model checking paths before editing
- Only restricts Write/Edit tool calls — Bash commands that write files are NOT blocked (use `/careful` for that)
- Relative paths are resolved against the project root
- Does not restrict Read/Grep/Glob — those remain unrestricted for exploration
