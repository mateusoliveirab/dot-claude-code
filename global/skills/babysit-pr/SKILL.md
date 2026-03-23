---
name: babysit-pr
description: Monitor a PR — retry flaky CI, resolve merge conflicts, notify on state changes. Use when the user says "babysit this PR", "watch this PR", "monitor PR", or wants to automate PR lifecycle after submission.
---

# Babysit PR

Monitors a pull request until it merges or the user cancels. Uses `/loop` for periodic polling.

## Workflow

1. **Identify PR** — get the PR number from the user or detect from current branch
2. **Start monitoring loop** — use `/loop 5m` to check every 5 minutes:
   - `git fetch origin` — sync remote state
   - Check CI status via commit status refs or branch protection state
   - Check for merge conflicts by attempting `git merge-tree`
3. **On CI failure:**
   - If flaky test (same test passed in recent history): suggest retry
   - If real failure: notify user with failure details and stop
4. **On merge conflict:**
   - `git fetch origin main && git rebase origin/main`
   - If conflict is trivial (lockfile, auto-generated): resolve and push
   - If conflict requires judgment: notify user and stop
5. **On all checks green + approved:**
   - Notify user "PR is ready to merge"
6. **Report** — on each loop iteration, log status silently. Only notify on state changes

## Gotchas

- Never force-push to someone else's PR branch
- Flaky test detection: compare against the last 3 runs, not just one
- Rate limit awareness: don't poll more than once per minute
- Always stop the loop after merge — don't leave orphan loops running
- Uses `git` CLI only (not `gh`) per project conventions
