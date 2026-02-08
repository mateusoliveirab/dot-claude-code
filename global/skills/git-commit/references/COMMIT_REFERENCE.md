# Git Commit Reference

## Conventional Commit Types

Use these prefixes in commit messages:

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add user authentication` |
| `fix` | Bug fix | `fix: resolve login timeout` |
| `docs` | Documentation | `docs: update API reference` |
| `style` | Code style (formatting) | `style: fix indentation` |
| `refactor` | Code refactoring | `refactor: simplify auth logic` |
| `test` | Tests | `test: add login tests` |
| `chore` | Maintenance | `chore: update dependencies` |

## Commit Message Format

```
<type>: <short summary>

[optional body]

[optional footer]
```

### Rules

1. **First line**: Max 50 characters, imperative mood
2. **Body**: Wrap at 72 characters, explain motivation
3. **Footer**: Reference issues, breaking changes

## Sensitive File Patterns

Never commit these:
- `.env` and `.env.*` files
- `credentials.json`, `secrets.json`
- Files with `password`, `token`, `key` in name
- SSH keys, certificates

## Quick Commands

```bash
# Check staged files
git diff --cached --name-only

# Check what will be committed
git diff --cached

# Stage specific files
git add <file1> <file2>

# Commit with message
git commit -m "type: description"
```
