---
name: git-pr
description: Create a pull request with comprehensive description (git CLI workflow)
auto_invoke: false
---

# Git PR Skill

Prepares for creating a pull request with a comprehensive description. This skill uses `git` CLI only (not `gh` CLI).

## Usage

```
/git-pr [target-branch]
```

Default target branch: `main`

## Workflow

When invoked:

1. **Check current state**:
   - Run `git status` to verify clean working tree
   - Run `git branch --show-current` to get current branch name
   - Check if branch tracks remote with `git rev-parse --abbrev-ref @{u}`

2. **Analyze changes**:
   - Run `git diff [target-branch]...HEAD` to see all changes in this branch
   - Run `git log [target-branch]..HEAD --oneline` to see all commits
   - Review ALL commits (not just the latest) to understand full scope

3. **Draft PR content**:
   - **Title**: Short (under 70 characters), descriptive
   - **Description**:
     ```markdown
     ## Summary
     - Bullet point 1
     - Bullet point 2
     - Bullet point 3

     ## Changes
     - List of key changes

     ## Testing
     - [ ] Manual testing completed
     - [ ] Tests added/updated
     - [ ] No console errors

     🤖 Generated with [Claude Code](https://claude.com/claude-code)
     ```

4. **Push to remote** (if needed):
   - If branch doesn't track remote: `git push -u origin <branch-name>`
   - If already tracking but behind: `git push`

5. **Provide PR creation instructions**:
   - Give user the PR title and description
   - Provide URL: `https://github.com/<user>/<repo>/compare/<target>...<branch>`
   - User will create PR via GitHub web interface

## Important Notes

- This skill does NOT create the PR (no `gh` CLI)
- It prepares the content and pushes the branch
- User creates PR manually via GitHub web UI
- Always analyze ALL commits in the branch, not just the latest one
