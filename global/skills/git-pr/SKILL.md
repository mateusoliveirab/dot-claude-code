---
name: git-pr
description: Prepare pull request content with comprehensive analysis using git CLI only (not gh CLI). Use when creating PRs, analyzing branch changes, or generating PR descriptions.
auto_invoke: false
compatibility: Requires git, bash. Works with GitHub, GitLab, Bitbucket via web interface.
metadata:
  author: Claude Code
  version: "1.0.0"
---

# Git PR Skill

Prepares comprehensive PR descriptions. Uses `git` CLI only, not `gh` CLI.

## Usage

```
/git-pr [target-branch]
```

Default target: `main`

## Workflow

1. **Analyze branch**: Run helper script for overview:
   ```bash
   scripts/analyze-pr.sh [target-branch]
   ```

2. **Check current state**:
   - Verify clean working tree
   - Get current branch name
   - Check remote tracking

3. **Review changes**:
   - Run `git diff [target]...HEAD` for full changes
   - Run `git log [target]..HEAD --oneline` for commits
   - Note file count and types

4. **Generate content**:
   - **Title**: Use format from [references/PR_REFERENCE.md](references/PR_REFERENCE.md)
   - **Description**: Use template from [assets/PR_TEMPLATE.md](assets/PR_TEMPLATE.md)
   - Include summary, changes, testing notes

5. **Output**: Present title and description in markdown format

## PR Content Format

### Title
```
<type>: Brief description (max 50 chars)
```

### Description Sections
1. **Summary** - What and why
2. **Changes** - Bullet list
3. **Testing** - How verified
4. **Related** - Issue links

## Scripts

- `scripts/analyze-pr.sh [target]` - Analyze branch and check readiness

## Reference

See [references/PR_REFERENCE.md](references/PR_REFERENCE.md) for:
- PR readiness checklist
- Change analysis commands
- Content creation guidelines

## Safety

- Never force push
- Verify branch state before suggesting PR
- Check for sensitive data in diff
