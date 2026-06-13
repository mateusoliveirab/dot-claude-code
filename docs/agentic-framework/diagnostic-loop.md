# Diagnostic Loop

Evidence-first RCA pattern for incidents, performance hot spots, flaky workflows, and ambiguous failures.

Use when an incorrect root cause would lead to the wrong fix.

---

## Four-Phase Architecture

```
Collect  ----\
              -> Diagnose -> Report
Correlate ---/
```

Collect and Correlate can run in parallel when they read independent sources. Diagnose waits for both.

## 1. Collect

Gather direct evidence from the primary system.

Examples:

- logs
- traces
- failing workflow runs
- exact error messages
- test output
- changed inputs
- slow spans

Output must be structured enough for another agent to use without rereading everything.

## 2. Correlate

Gather independent signals that can confirm or refute the primary evidence.

Examples:

- infrastructure metrics
- deploy history
- database metrics
- queue depth
- dependency health
- related service errors
- recent config changes

The point is not to collect more data. The point is to find signals that can disprove a convenient explanation.

## 3. Diagnose

Build a root cause from evidence, not narrative.

Use a 5-Why chain starting from the most concrete observed anomaly.

Each why must move one level deeper:

1. What happened?
2. Why did that behavior occur?
3. Why did the system allow it?
4. What mechanism, lifecycle hook, guardrail, or design assumption was missing?
5. What structural change prevents recurrence?

If a step only restates the symptom, challenge it once:

> That describes what happened, not why the system allowed it. One level deeper: what mechanism was absent, or what design assumption was wrong?

## 4. Report

Write the final report from the artifacts:

- root cause
- evidence
- 5-Why chain
- rejected alternatives
- remediation
- blast radius
- confidence
- unresolved questions

If the evidence does not support a root cause, say that. A best-effort diagnosis must be labeled as best-effort.

---

## Challenge Gate

Before remediation, challenge the diagnosis.

Prompt shape:

```text
Find the strongest flaw in this root cause.
Look for missing evidence, arithmetic errors, alternative explanations, and unsupported causal jumps.
Return: confirmed, partial, or rejected.
```

Verdicts:

| Verdict | Action |
|---|---|
| `confirmed` | Proceed to remediation |
| `partial` | Adopt the revised root cause, then proceed |
| `rejected` | Re-run diagnosis with challenge issues injected |
| `exhausted` | Proceed only as best-effort and mark confidence explicitly |

Retry cap: 2 challenge retries. After that, report the remaining uncertainty instead of looping.

Use a stronger model or fresh-context reviewer for this gate when the downstream fix is expensive or risky.

---

## Remediation And Blast Radius

After a challenged diagnosis, draft the smallest fix that addresses the root cause.

Then run a blast-radius gate:

- Does the fix address the root cause, not just the symptom?
- What dependent systems can be affected?
- Is the change safe for the current deployment window?
- What rollback or stop condition exists?
- What test or metric proves the fix worked?

Verdicts:

| Verdict | Action |
|---|---|
| `proceed` | Ship or recommend the fix |
| `revise` | Rework the fix with constraints injected |
| `exhausted` | Mark `fix_risky=true`; do not hide residual risk |

Retry cap: 2 blast-radius retries.

---

## Artifact Contract

Each phase should pass structured artifacts, not loose conversation history.

Minimum diagnosis artifact:

```json
{
  "root_cause": "",
  "evidence": [],
  "five_why": [],
  "alternatives": [],
  "confidence": 0
}
```

Minimum challenge artifact:

```json
{
  "verdict": "confirmed | partial | rejected",
  "issues": [],
  "revised_root_cause": null
}
```

Minimum blast artifact:

```json
{
  "verdict": "proceed | revise",
  "risk_level": "low | medium | high",
  "affected_systems": [],
  "constraints": []
}
```
