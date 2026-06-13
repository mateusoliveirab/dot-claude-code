# Principles

## Context Is Infrastructure

Agents are only as good as the context they receive. Keep project instructions, runbooks, state, and source-of-truth mappings current.

Stale context is worse than missing context because it creates confident wrong action.

## Feedback Closes The Loop

Every agent needs a signal for success, failure, and noise.

Examples: test output, metric query, API response, user rejection, issue state, PR review, or state file diff.

## Autonomy Is Earned

Start with suggestions, then safe actions, then audited autonomy.

Never grant more authority than the problem requires.

## Least Agency

Prefer the narrowest agent, toolset, permission set, and blast radius that can solve the task.

If a read-only workflow solves the problem, do not give write access. If one repo is enough, do not give all repos.

## Guardrails Create Freedom

Good boundaries, state, observability, and rollback paths let agents act without asking for every step.

Weak guardrails do not make agents faster. They make errors harder to contain.

## Specialization Scales

One broad agent becomes hard to debug.

Use focused agents coordinated by explicit artifacts, policies, and handoff contracts.
