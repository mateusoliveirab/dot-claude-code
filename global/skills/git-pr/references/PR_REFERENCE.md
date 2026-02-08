# Git PR Reference

## PR Readiness Checklist

Before creating a PR:

- [ ] Working tree is clean (no uncommitted changes)
- [ ] Branch is up to date with target
- [ ] Tests pass
- [ ] Code follows project conventions
- [ ] Self-review completed

## Analyzing Branch Changes

```bash
# See commits ahead of main
git log main..HEAD --oneline

# See files changed
git diff main...HEAD --name-only

# See full diff
git diff main...HEAD
```

## Creating PR Content

### Title Format

```
<type>: Brief description
```

Examples:
- `feat: add user authentication`
- `fix: resolve memory leak in parser`
- `docs: update installation guide`

### Description Sections

1. **Summary** - What and why
2. **Changes** - Bullet list of modifications
3. **Testing** - How it was tested
4. **Related** - Issue links

## Commands Reference

```bash
# Check current branch
git branch --show-current

# Check if tracking remote
git rev-parse --abbrev-ref @{u}

# See commit count
git rev-list --count main..HEAD

# Check for uncommitted changes
git diff-index --quiet HEAD --
```
