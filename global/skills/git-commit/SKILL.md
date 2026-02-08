---
name: git-commit
description: Create well-formatted commits using conventional commits. Groups related changes by functionality. Use when committing staged changes or preparing commits.
auto_invoke: false
compatibility: Requires git, bash. Works in any git repository.
metadata:
  author: User
  version: "2.0.0"
---

# Git Commit

Creates well-formatted commits following conventional commits. Groups related changes by functionality rather than atomic file-by-file commits.

## Usage

```
/git-commit [optional message]
```

## Workflow

1. **Analyze changes**:
   ```bash
   scripts/commit-helper.sh analyze
   ```
   - Shows modified files grouped by category
   - Suggests commit type based on changes

2. **Review and group**:
   - Group related files (same functionality)
   - Don't do atomic commits per file
   - Make commits per feature/bug/refactor

3. **Create message**:
   ```bash
   scripts/commit-helper.sh suggest
   ```
   - Suggests message based on staged files
   - Follows conventional commits format

4. **Execute**:
   ```bash
   git add <related-files>
   git commit -m "type: description"
   ```

## Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style/formatting (no logic change)
- `refactor` - Code refactoring
- `test` - Tests
- `chore` - Maintenance tasks

**Rules**:
- First line: max 50 characters
- Imperative mood: "Add" not "Added"
- Clear description of what changes
- Optional body explains why

## Scripts

- `scripts/commit-helper.sh analyze` - Analyzes and groups changes
- `scripts/commit-helper.sh suggest` - Suggests commit message
- `scripts/commit-helper.sh validate` - Validates message format
- `scripts/commit-helper.sh summary` - Shows analysis summary

## Best Practices

- Commit by functionality, not by file
- Use specific `git add`, never `git add .`
- Small, focused commits
- Message explains "what", body explains "why"

## Safety

- Never commit sensitive files (.env, tokens)
- Always review before committing
- Don't use --no-verify
