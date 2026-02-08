---
name: git-pr
description: Prepare comprehensive PR content for manual creation. Use when analyzing branch changes, generating PR descriptions, or preparing to open a pull request.
auto_invoke: false
compatibility: Requires git, bash. Works with GitHub, GitLab, Bitbucket via web interface.
metadata:
  author: User
  version: "2.0.0"
---

# Git PR

Prepares comprehensive PR content for manual creation. I prefer to open PRs manually because it's the moment I review and ensure everything is correct.

## Usage

```
/git-pr [target-branch]
```

Default target: `main`

## Why Manual PR Creation?

Opening PRs manually allows me to:
- Review all changes one final time before submitting
- Verify the PR title and description are accurate
- Check that only intended changes are included
- Ensure quality before sharing with the team

## Workflow

1. **Analyze branch**:
   ```bash
   scripts/pr-helper.sh analyze [target-branch]
   ```

2. **Generate PR content**:
   ```bash
   scripts/pr-helper.sh generate [target-branch]
   ```
   Creates complete PR description in the format below

3. **Review output**:
   - Read the generated title and description
   - Verify all sections are accurate

4. **Open PR manually**:
   - Go to GitHub/GitLab web interface
   - Use the generated title and description
   - Submit the PR

## PR Format

### Title
```
<type>: Brief description
```

Examples:
- `feat: add user authentication`
- `fix: resolve memory leak in parser`
- `docs: update installation guide`

### Description Template

```markdown
## Summary
Brief overview of what this PR accomplishes.

## What, Why & Benefits

**What:**
- Change 1
- Change 2

**Why:**
Explanation of the motivation behind these changes

**Benefits:**
- Benefit 1
- Benefit 2

## Validation
- [ ] Code follows project conventions
- [ ] Self-review completed
- [ ] No sensitive data in changes
- [ ] Tests pass locally

## Changes
| File | Change |
|------|--------|
| `path/to/file1` | Brief description |
| `path/to/file2` | Brief description |

## Testing/Validations
- [ ] Tested locally
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
```

## Scripts

- `scripts/pr-helper.sh analyze [target]` - Analyze branch changes
- `scripts/pr-helper.sh generate [target]` - Generate complete PR content
- `scripts/pr-helper.sh summary [target]` - Show branch summary

## Best Practices

- Always review generated content before using
- Ensure description accurately reflects changes
- Include context for reviewers
- Check all validation checkboxes

## Safety

- Never include sensitive data in PR descriptions
- Verify branch is clean before generating
- Double-check target branch is correct
