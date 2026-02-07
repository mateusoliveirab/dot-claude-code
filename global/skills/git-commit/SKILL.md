---
name: git-commit
description: Streamlined git commit workflow with best practices
auto_invoke: false
---

# Git Commit Skill

Creates a well-formatted git commit following best practices.

## Usage

```
/git-commit [optional message]
```

## Workflow

When invoked:

1. **Check status**: Run `git status` to see staged and unstaged changes
2. **Show diff**: Run `git diff --staged` to review what will be committed
3. **Analyze changes**: Review the diff to understand the scope and nature of changes
4. **Draft commit message**: Create a concise, descriptive commit message:
   - Use imperative mood ("Add feature" not "Added feature")
   - First line: 50 chars max, summarize the "what"
   - Optional body: Explain the "why" if needed
   - Follow project conventions from recent commits (`git log --oneline -5`)
5. **Stage files**: If needed, add specific files with `git add <files>`
6. **Create commit**: Run `git commit -m "message"` (use heredoc for multi-line)
7. **Verify**: Run `git log -1` to confirm the commit

## Best Practices

- Never use `git add .` or `git add -A` unless explicitly requested (can include sensitive files)
- Prefer adding specific files by name
- Check for sensitive files (.env, credentials.json, etc.) before staging
- Never commit with `--no-verify` unless user explicitly requests it
- Add co-authorship line when appropriate:
  ```
  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```

## Safety

- Never run destructive commands (reset --hard, checkout ., etc.)
- Always show what will be committed before committing
- Skip this skill if no changes to commit
