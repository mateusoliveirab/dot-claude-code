---
description: Git conventions for commits and pull requests
---

# Git

## Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:** `feat` · `fix` · `docs` · `style` · `refactor` · `test` · `chore`

**Rules:**
- First line: max 50 chars, imperative mood ("Add" not "Added")
- Group related files into one commit by logical change — not one commit per file
- Always use specific `git add <files>` — never `git add .` or `git add -A`
- Check for sensitive files (.env, credentials, keys) before staging
- Run `git diff --staged --stat` before committing to confirm scope
- If a pre-commit hook fails, fix the issue and create a **new** commit — never `--amend` the previous one
- Never use `--no-verify` unless explicitly requested

## Pull Requests

Title: `<type>: brief description`

Body: what changed, why it changed, how to validate. Keep it short.

Open PRs manually via the web interface — never auto-create with `gh pr create` unless explicitly asked.
