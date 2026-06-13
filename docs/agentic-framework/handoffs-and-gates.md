# Handoffs And Gates

Multi-agent work fails when agents pass vibes instead of artifacts.

Use structured handoffs and explicit gates whenever the next step depends on the previous step being correct.

---

## Artifact Handoff

Each agent should receive the previous artifact as structured data, not the full conversation.

Good handoff:

```json
{
  "claim": "",
  "evidence": [],
  "confidence": 0,
  "unknowns": [],
  "next_action": ""
}
```

Bad handoff:

```text
Here is everything we talked about. Continue from here.
```

Rules:

- Keep only what the next phase needs.
- Include evidence references, not just conclusions.
- Include confidence and unresolved questions.
- Do not pass hidden chain-of-thought or broad chat history as the contract.
- If a gate rejects an artifact, inject the rejection as structured context into the previous phase.

---

## Confidence

Confidence should describe evidence quality, not tone.

Use a simple scale:

| Level | Meaning |
|---|---|
| `high` | Directly verified from source, command, metric, log, test, or API response |
| `medium` | Inferred from multiple consistent signals, but not directly proven |
| `low` | Plausible hypothesis; human or later phase must validate |

Low confidence is acceptable when it is labeled. Hidden uncertainty is not.

---

## Human Gates

Use human gates when judgment matters more than execution speed.

Good gate points:

- after initial brief, before deep planning
- after plan, before implementation
- before destructive or production changes
- before creating external tickets, PRs, or notifications
- when confidence stays low after validation

Human-on-the-loop means the human supervises batches and decisions, not every micro-step.

Gate decisions should be explicit:

| Decision | Meaning |
|---|---|
| `approved` | Continue |
| `rejected` | Stop and record why |
| `needs_clarification` | Stop until an open question is answered |
| `waiting` | Keep state; revisit in the next run |

---

## Terminal States

Every loop needs terminal states.

Do not let agents retry forever. Use bounded cycles and name the final state.

Examples:

| State | Meaning |
|---|---|
| `confirmed` | Evidence supports the artifact |
| `partial` | Direction is useful, but caveats must be carried forward |
| `rejected` | Artifact must be reworked |
| `exhausted` | Retry budget ended; proceed only as best-effort or stop |
| `blocked` | Required evidence or permission is missing |

If a loop exits as `partial` or `exhausted`, the report must preserve that uncertainty.
