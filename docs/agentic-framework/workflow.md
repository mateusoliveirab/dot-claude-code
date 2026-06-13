# Default Workflow

Use this shape for non-trivial work.

## 1. Research

Read the system before proposing a change.

Produce:

- relevant files and owners
- real anchors: paths, functions, workflows, metrics, issues, or logs
- known constraints
- unknowns that still matter
- existing patterns that should be reused

Exit when you can explain the system without guessing.

## 2. Plan

Turn research into a concrete execution path.

Produce:

- numbered steps
- files or systems touched
- expected outcome per step
- validation command or evidence per step
- rollback or stop condition for risky work

Exit when another capable agent could execute the plan without ambiguity.

## 3. Implement

Make the smallest coherent change.

If the plan is wrong, return to planning. Do not silently improvise through a different design.

## 4. Verify

Run the thing that proves the change works.

Examples:

- test command
- lint or syntax check
- dry-run
- endpoint call
- browser check
- metric query
- state comparison

## 5. Document

Capture durable knowledge in the right place: README, CLAUDE.md, runbook, state file, issue, or PR description.

Write from what actually happened, not from what was expected.

## Context Rule

Keep context lean. Split phases or use subagents when context from one phase would pollute the next.
