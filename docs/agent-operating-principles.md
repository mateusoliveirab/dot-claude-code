# Agent Operating Principles

Principles for autonomous and scheduled agents that operate without constant supervision.

---

## 1. Persistent State

Recurring agents must not rely solely on session context. Use persistent state when the agent needs to compare runs or carry decisions across executions.

**Minimum schema:**

```json
{
  "last_run": "<ISO 8601 timestamp>",
  "ignore": [],
  "backlog": [],
  "escalation": []
}
```

**Field semantics:**

| Field | Purpose |
|---|---|
| `last_run` | Enables diff-driven scoping — only process what changed since the previous run |
| `ignore` | Human veto list; once an item is added here, the agent must never re-raise it |
| `backlog` | Unresolved findings that do not require immediate escalation |
| `escalation` | Items queued for human briefing or notification |

**Storage:** Keep state in a stable, unversioned path (e.g., `~/.claude/projects/<project>/state/agent-state.json`). Never commit runtime state to git.

---

## 2. Autonomy Tiers

Every finding must map to exactly one tier. When in doubt, use the higher tier (less autonomous action).

| Tier | Label | Action |
|---|---|---|
| 1 | Auto-fix | Fix, test, and report |
| 2 | Apply + flag | Fix, test, and surface residual risk |
| 3 | Flag only | Record in backlog or tasks without touching the system |
| 4 | Escalate | Notify as urgent; take no further action |

**Tier assignment rules:**

- **Tier 1** — The change is local and fully reversible, tests exist and pass, and no shared or live state is affected.
- **Tier 2** — The fix is clear and low-risk, but there is a non-trivial side effect or assumption the human should be aware of.
- **Tier 3** — The correct action requires context the agent does not have, or the change affects live systems, credentials, configuration, or irreversible state.
- **Tier 4** — The finding implies real impact: service down, authentication failure, data loss, or a guardrail failing or bypassed.

---

## 3. Zero Noise

An agent that produces noise loses utility. Every output item must justify its existence.

- Do not duplicate a finding already in `backlog`, `ignore`, or an open task.
- Do not reopen an item listed in `ignore`.
- If nothing changed since `last_run`, update the timestamp and exit silently.
- Prefer updating an existing item over creating a new one.
- Every anomaly must include concrete evidence: command, timestamp, file path, log line, or metric. No vague observations.

---

## 4. Escalation

Escalate when there is real impact or a meaningful risk of harm.

**Escalation record format:**

```json
{
  "severity": "critical | high | medium",
  "type": "<category>",
  "subject": "<affected component>",
  "summary": "<one sentence — what happened>",
  "reference": "<file, command, log, issue, or task>",
  "first_escalated": "<ISO 8601 timestamp>"
}
```

**Severity definitions:**

| Level | Criteria |
|---|---|
| `critical` | Service down, data loss, security breach, or guardrail bypassed |
| `high` | Degraded but functional; time-sensitive intervention required |
| `medium` | Non-urgent; human should review before the next scheduled run |

---

## 5. Actionable Outputs

Every report must answer these five questions. If the agent cannot answer all five, it should escalate rather than report.

1. What was observed?
2. Which component is affected?
3. What evidence supports this?
4. What action was taken (if any)?
5. What still requires a human decision?

**Example:**

```
Component: api-worker (systemd unit)
Observed: Unit inactive since 2026-06-10T14:22:00Z
Evidence: journalctl -u api-worker --since "1 hour ago" shows exit code 1
Action taken: None (Tier 3 — live service)
Requires human: Confirm cause before restarting.
  Suggested command: systemctl status api-worker
```

Avoid vague language. "May need attention" is not actionable. "Restart service X after confirming Y" is.

---

## 6. Hard Boundaries

These rules take precedence over all other instructions.

Never:
- Hardcode credentials or secrets in any file
- Take destructive actions (delete, drop, truncate, force-push) without explicit human confirmation
- Commit changes without an explicit request
- Bypass or relax a guardrail to make a task easier
- Treat cached or stale data as a source of truth for live decisions
- Silently swallow errors — if an action fails, log it and escalate if warranted
