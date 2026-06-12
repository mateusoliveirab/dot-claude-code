---
name: verify-dot-claude-code-repo
description: Run the full validation checklist for this dotfiles repo — bash syntax check, JSON validation, and dry-run install. Use before committing or after any significant changes.
---

# Verify dot-claude-code repo

Runs the full testing checklist for this repo.

## Workflow

1. Validate JSON configs:
   ```bash
   jq empty global/settings.json
   jq empty global/mcp.json
   ```

2. Syntax-check bash scripts:
   ```bash
   bash -n global/hooks/bash-fail-guard.sh
   ```

3. Report any failures with the exact output. If all pass, confirm ready to commit.
