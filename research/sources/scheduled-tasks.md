# Scheduled Tasks (Session-Scoped Cron)

> Source: https://code.claude.com/docs/en/scheduled-tasks
> Captured: 2026-03-22

> Requires Claude Code v2.1.72 or later. Check with `claude --version`.

## Overview

Scheduled tasks let Claude re-run a prompt automatically on an interval within a session. Use for:
- Polling a deployment
- Babysitting a PR
- Checking back on a long-running build
- One-time reminders

**Session-scoped**: tasks live in the current Claude Code process and are gone when you exit.

For durable scheduling that survives restarts, see [Desktop scheduled tasks](/en/desktop#schedule-recurring-tasks) or [GitHub Actions](/en/github-actions).

To react to events as they happen instead of polling, see [Channels](/en/channels).

## Schedule a Recurring Prompt with `/loop`

```text
/loop 5m check if the deployment finished and tell me what happened
```

Claude parses the interval, converts it to a cron expression, schedules the job, and confirms the cadence and job ID.

### Interval Syntax

| Form                    | Example                               | Parsed interval              |
| ----------------------- | ------------------------------------- | ---------------------------- |
| Leading token           | `/loop 30m check the build`           | every 30 minutes             |
| Trailing `every` clause | `/loop check the build every 2 hours` | every 2 hours                |
| No interval             | `/loop check the build`               | defaults to every 10 minutes |

**Supported units:** `s` (seconds), `m` (minutes), `h` (hours), `d` (days). Seconds round up to nearest minute.

### Loop Over Another Command

```text
/loop 20m /review-pr 1234
```

Each time the job fires, Claude runs `/review-pr 1234` as if typed manually.

## One-Time Reminders

Use natural language instead of `/loop`:

```text
remind me at 3pm to push the release branch
```

```text
in 45 minutes, check whether the integration tests passed
```

Claude creates a single-fire task that deletes itself after running.

## Manage Scheduled Tasks

```text
what scheduled tasks do I have?
```

```text
cancel the deploy check job
```

### Underlying Tools

| Tool         | Purpose                                                                                                         |
| ------------ | --------------------------------------------------------------------------------------------------------------- |
| `CronCreate` | Schedule a new task. Accepts a 5-field cron expression, the prompt to run, and whether it recurs or fires once. |
| `CronList`   | List all scheduled tasks with their IDs, schedules, and prompts.                                                |
| `CronDelete` | Cancel a task by ID.                                                                                            |

Each task has an 8-character ID. Max 50 scheduled tasks per session.

## How Scheduled Tasks Run

- Scheduler checks every second for due tasks
- Tasks enqueue at low priority
- A scheduled prompt fires **between turns**, not while Claude is mid-response
- If Claude is busy when a task fires, it waits until the current turn ends
- All times interpreted in **local timezone** (not UTC)

### Jitter

To avoid API spikes at exact wall-clock moments:
- **Recurring tasks**: fire up to 10% of their period late, capped at 15 minutes (e.g., hourly job fires `:00`–`:06`)
- **One-shot tasks**: scheduled for top/bottom of hour fire up to 90 seconds early

The offset is derived from the task ID (deterministic).

**Tip:** Pick a non-standard minute (e.g., `3 9 * * *` instead of `0 9 * * *`) to avoid jitter on one-shot tasks.

### Three-Day Expiry

Recurring tasks automatically expire 3 days after creation. The task fires one final time, then deletes itself.

To keep a recurring task longer, cancel and recreate it before it expires.

## Cron Expression Reference

Standard 5-field: `minute hour day-of-month month day-of-week`

All fields support: `*` (wildcard), single values (`5`), steps (`*/15`), ranges (`1-5`), lists (`1,15,30`).

| Example        | Meaning                      |
| -------------- | ---------------------------- |
| `*/5 * * * *`  | Every 5 minutes              |
| `0 * * * *`    | Every hour on the hour       |
| `7 * * * *`    | Every hour at 7 minutes past |
| `0 9 * * *`    | Every day at 9am local       |
| `0 9 * * 1-5`  | Weekdays at 9am local        |
| `30 14 15 3 *` | March 15 at 2:30pm local     |

Day-of-week: `0` or `7` = Sunday, `6` = Saturday. Extended syntax (`L`, `W`, `?`, name aliases) **not supported**.

When both day-of-month and day-of-week are constrained, a date matches if **either** field matches (vixie-cron semantics).

## Disable Scheduled Tasks

```bash
CLAUDE_CODE_DISABLE_CRON=1
```

The cron tools and `/loop` become unavailable; already-scheduled tasks stop firing.

## Limitations

- Tasks only fire while Claude Code is running and idle
- **No catch-up** for missed fires: fires once when Claude becomes idle, not per missed interval
- **No persistence** across restarts: restarting Claude Code clears all session-scoped tasks
