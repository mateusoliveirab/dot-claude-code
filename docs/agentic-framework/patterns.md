# Orchestration Patterns

## gate -> job -> gate

Validate before and after risky work.

Use for mutating operations, production changes, permission grants, deletes, migrations, and anything where silent failure is worse than stopping.

Flow:

1. Pre-gate: read current state, check preconditions, surface risk.
2. Job: apply the change within explicit boundaries.
3. Post-gate: query resulting state, confirm intent, detect side effects.

Skip for read-only work or reversible low-risk edits where the gate costs more than the risk.

## describe-after-apply

Write the final description from what happened, not from what was expected.

Use when outputs are only known after execution:

- generated IDs
- PR diffs
- URLs
- resource names
- failed steps
- side effects

## research + plan + implement

Separate discovery, reasoning, and execution.

Use when there are multiple unknowns, cross-repo dependencies, unclear ownership, or a high cost of backing out.

## reflect -> critique -> revise

Use a stronger or fresh-context reviewer to challenge a draft conclusion, then revise with the critique injected as structured context.

Good for:

- root cause analysis
- architecture decisions
- security-sensitive changes
- incident reports
- large refactors

Limit retries. Endless critique loops are usually a sign that evidence is missing.
