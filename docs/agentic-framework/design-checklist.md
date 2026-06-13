# Design Checklist

Before creating or expanding an agent, answer these questions.

## Responsibility

- What is its single responsibility?
- What work is explicitly out of scope?
- What existing agent, skill, script, or workflow already covers part of this?

## Context

- What context does it need?
- Where does that context live?
- Which source is authoritative?
- How does it detect stale context?

## Authority

- What can it do autonomously?
- What must it only flag?
- What requires human confirmation?
- What tools and permissions are actually necessary?

## State

- What must persist across runs?
- How does a human veto a noisy finding?
- How are duplicate findings avoided?
- What marks an item resolved?

## Risk

- What is the worst thing it can do if it misbehaves?
- What is the rollback path?
- What is the stop condition?
- What should never be modified?

## Verification

- What command, query, metric, or test proves success?
- What evidence proves failure?
- What gets reported if verification is inconclusive?

Do not make a task agentic just because it can be agentic. Automation without feedback, state, and boundaries is just faster uncertainty.
