---
name: verify-dot-claude-code-repo
description: Run the full validation checklist for this dotfiles repo — bash syntax check, JSON validation, and dry-run install. Use before committing or after any significant changes.
---

# Verify dot-claude-code repo

Runs the full testing checklist for this repo.

## Workflow

1. Syntax-check the install script:
   ```bash
   bash -n install.sh
   ```

2. Validate JSON configs:
   ```bash
   jq empty global/settings.json
   jq empty global/mcp.json
   ```

3. Dry-run the install (pass `R` to auto-resolve any conflict prompts):
   ```bash
   printf 'R\n' | bash install.sh --dry-run
   ```
   Check the output for errors. Expected: files listed as `✓` or `~`, no error lines, ends with `(dry-run — no changes made)`.

4. Report any failures with the exact output. If all pass, confirm ready to commit.
