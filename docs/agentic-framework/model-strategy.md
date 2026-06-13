# Model Strategy

Use the cheapest model that can safely do the phase.

Model choice is part of system design. Do not spend frontier reasoning on bulk collection, and do not use weak reasoning where a wrong answer drives a risky action.

---

## Phase Routing

| Work type | Model shape | Rationale |
|---|---|---|
| Bulk collection, extraction, formatting | small or cheap model | High volume, low judgment |
| Correlation across sources | mid-tier model | Needs synthesis, not deep strategy |
| Planning and implementation | mid-tier or strong model | Needs coherent edits and validation |
| Challenge, arbitration, high-risk judgment | strongest available model | Wrong conclusion has high downstream cost |
| Final report from verified artifacts | mid-tier model | Mostly synthesis from structured data |

The strongest model should usually appear at gates, not everywhere.

---

## Challenge-Only Frontier Use

A useful pattern:

1. Cheaper agents collect and structure evidence.
2. A capable executor builds the diagnosis or plan.
3. A stronger challenger tries to refute it.
4. The executor revises only if the challenge finds real gaps.

This keeps cost bounded while applying better reasoning where it matters most.

---

## Parallelism

Parallelize work when streams are independent.

Good fits:

- collecting from independent data sources
- reviewing separate modules
- generating briefs for unrelated tickets
- testing competing hypotheses

Bad fits:

- same-file edits
- sequential decisions
- subtasks where one output is required by another
- work with high merge-conflict risk

Independence check:

> Can each subtask be described without referencing another subtask's output?

If not, run sequentially.

---

## Cost And Cache Discipline

- Keep static instructions stable.
- Pass compact artifacts between phases.
- Avoid changing toolsets mid-workflow unless the phase requires it.
- Use retry caps on challenge and validation loops.
- Record model choice only when it affects cost, quality, or safety.
