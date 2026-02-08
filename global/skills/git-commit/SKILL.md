---
name: git-commit
description: Streamlined git commit workflow with best practices including sensitive file detection and conventional commit format validation. Use when creating commits, staging files, or validating commit messages.
auto_invoke: false
compatibility: Requires git, bash. Works in any git repository.
metadata:
  author: Claude Code
  version: "1.0.0"
---

# Git Commit Skill

Creates well-formatted commits following best practices. Validates for sensitive files and ensures proper message format.

## Usage

```
/git-commit [optional message]
```

## Workflow

1. **Check status**: Run `git status` to see staged/unstaged changes
2. **Show diff**: Run `git diff --staged` to review what will be committed
3. **Validate**: Use helper script to check for sensitive files:
   ```bash
   scripts/validate-commit.sh --check-sensitive
   ```
4. **Analyze**: Review changes to understand scope
5. **Draft message**: Create concise, descriptive message following conventions from [references/COMMIT_REFERENCE.md](references/COMMIT_REFERENCE.md)
6. **Validate message**: Check format:
   ```bash
   scripts/validate-commit.sh --message <msg-file>
   ```
7. **Stage files**: Add specific files with `git add <files>`
8. **Create commit**: Run `git commit -m "message"` (use heredoc for multi-line)
9. **Verify**: Run `git log -1` to confirm

## Message Format

- **Type prefix**: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`
- **First line**: Max 50 chars, imperative mood ("Add" not "Added")
- **Body**: Optional, explain the "why" if needed

## Best Practices

- Never use `git add .` or `git add -A` (can include sensitive files)
- Always stage files individually by name
- Check [references/COMMIT_REFERENCE.md](references/COMMIT_REFERENCE.md) for sensitive file patterns
- Never commit with `--no-verify` unless explicitly requested
- Add co-authorship when appropriate: `Co-Authored-By: Name <email>`

## Scripts

- `scripts/validate-commit.sh --check-sensitive` - Detect sensitive files
- `scripts/validate-commit.sh --message <file>` - Validate message format

## Safety

- Never run destructive commands (reset --hard, checkout ., etc.)
- Always show what will be committed before committing
- Skip if no changes present
