---
name: git-commit
description: Create well-formatted commits using conventional commits. Use when committing staged changes, the user says "commit this", invokes /git-commit, or finishes a task and wants to save progress.
---

# Git Commit

Creates well-formatted commits following conventional commits. Groups related changes by functionality rather than atomic file-by-file commits.

## Usage

```
/git-commit [optional message]
```

## Workflow

Track progress through these steps:

- [ ] Step 1: Analyze changes (LOW freedom)
- [ ] Step 2: Review and group (MED freedom)
- [ ] Step 3: Create commit message (MED freedom)
- [ ] Step 4: Stage and commit (LOW freedom)
- [ ] Step 5: Verify (LOW freedom)

### Step 1: Analyze changes (LOW freedom)

Run in parallel:

```bash
git status
git diff --staged
git diff
git log --oneline -5
```

**Validation**: If no staged or unstaged changes exist, stop and inform the user. Do not create empty commits.

### Step 2: Review and group (MED freedom)

- Group related files by functionality (same feature/bug/refactor)
- Don't do atomic commits per file — commit per logical change
- Identify the commit type from the changes

### Step 3: Create commit message (MED freedom)

Format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Rules**:
- First line: max 50 characters
- Imperative mood: "Add" not "Added"
- Match style from recent commits (Step 1)

**Validation**: If the user provided a message argument, use it as-is. Otherwise, present the draft and wait for confirmation before committing.

### Step 4: Stage and commit (LOW freedom)

```bash
git add <related-files>
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<optional body>

Co-Authored-By: Claude <model> <noreply@anthropic.com>
EOF
)"
```

- Use specific `git add` — never `git add .` or `git add -A` unless explicitly requested
- Check for sensitive files (.env, credentials, keys) before staging

**Validation**: Run `git diff --staged --stat` before committing to confirm only intended files are staged.

### Step 5: Verify (LOW freedom)

```bash
git log -1
```

**Validation**: If pre-commit hooks fail, fix the issue and create a NEW commit (never --amend the previous one unless explicitly asked).

## Example

**Input**: User runs `/git-commit` after editing `src/auth.ts` and `src/auth.test.ts`

**Agent output**:
```
Changes detected:
  M src/auth.ts        — added token refresh logic
  M src/auth.test.ts   — added tests for token refresh

Proposed commit:
  feat(auth): add token refresh logic

Proceed?
```

After confirmation:
```bash
git add src/auth.ts src/auth.test.ts
git commit -m "$(cat <<'EOF'
feat(auth): add token refresh logic

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

**Input**: User runs `/git-commit "fix: typo in readme"`

**Agent behavior**: Uses the provided message directly, stages relevant files, commits without asking for confirmation on the message.

## Safety

- Never run destructive commands (reset --hard, checkout ., push --force)
- Never commit sensitive files (.env, tokens, credentials)
- Always review before committing
- Never use `--no-verify` unless user explicitly requests
- Skip if no changes to commit
