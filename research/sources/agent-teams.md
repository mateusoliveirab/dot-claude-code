# Agent Teams — Orchestrate Multiple Claude Code Sessions

> Source: https://code.claude.com/docs/en/agent-teams
> Captured: 2026-03-22

> **Experimental** — disabled by default. Requires Claude Code v2.1.32+.

## Enable

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Overview

Agent teams let you coordinate multiple Claude Code instances working together:
- One session acts as the **team lead** (coordinates work, assigns tasks, synthesizes results)
- **Teammates** work independently, each in its own context window
- Teammates can communicate directly with each other (unlike subagents)

## When to Use Agent Teams

**Best for:**
- Research and review (multiple teammates investigate different aspects simultaneously)
- New modules/features (each teammate owns a separate piece)
- Debugging with competing hypotheses (test different theories in parallel)
- Cross-layer coordination (frontend, backend, tests — each owned by different teammate)

**Not for:**
- Sequential tasks
- Same-file edits
- Work with many dependencies
→ Use a single session or [subagents](/en/sub-agents) instead

## Subagents vs Agent Teams

| | Subagents | Agent Teams |
| - | --------- | ----------- |
| **Context** | Own context window; results return to caller | Own context window; fully independent |
| **Communication** | Report results back to main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |

## Start Your First Agent Team

```text
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.
```

Claude creates a team with a shared task list, spawns teammates, has them explore, synthesizes findings, and cleans up the team when finished.

The lead's terminal lists all teammates and what they're working on.
- **In-process mode**: use `Shift+Down` to cycle through teammates
- **Split-pane mode**: each teammate in its own pane

## Display Modes

| Mode | Description | Requires |
| ---- | ----------- | -------- |
| `in-process` | All teammates run inside main terminal; `Shift+Down` to cycle | Any terminal |
| `tmux` | Each teammate gets its own pane | tmux or iTerm2 |
| `auto` (default) | Split panes if already in tmux session, in-process otherwise | — |

```json
// Override in settings.json
{ "teammateMode": "in-process" }

// Or per session
claude --teammate-mode in-process
```

## Control Your Team

### Specify Teammates and Models

```text
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Require Plan Approval

```text
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

Flow: teammate works in read-only plan mode → sends plan approval request to lead → lead approves/rejects with feedback → if approved, teammate exits plan mode and begins implementation.

### Talk to Teammates Directly

- **In-process**: `Shift+Down` to cycle → type to send message; `Enter` to view session; `Escape` to interrupt; `Ctrl+T` to toggle task list
- **Split-pane**: click into a pane to interact

### Assign and Claim Tasks

The shared task list coordinates work:
- Tasks: pending → in progress → completed
- Tasks can have dependencies (blocked until dependencies complete)
- Lead can assign explicitly, or teammates self-claim
- File locking prevents race conditions

### Shut Down and Clean Up

```text
Ask the researcher teammate to shut down
```

```text
Clean up the team
```

> Always use the **lead** to clean up. Teammates should not run cleanup (may leave resources in inconsistent state).

## Architecture

| Component | Role |
| --------- | ---- |
| **Team lead** | Creates team, spawns teammates, coordinates work |
| **Teammates** | Separate Claude Code instances, work on assigned tasks |
| **Task list** | Shared work items that teammates claim and complete |
| **Mailbox** | Messaging system for inter-agent communication |

**Storage:**
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

## Context and Communication

Each teammate loads:
- CLAUDE.md, MCP servers, skills (from project)
- Spawn prompt from the lead
- **NOT** the lead's conversation history

**Sharing information:**
- Messages delivered automatically (lead doesn't need to poll)
- Idle notifications sent automatically when teammate finishes
- Shared task list visible to all agents

**Messaging:**
- `message`: send to one specific teammate
- `broadcast`: send to all simultaneously (use sparingly — costs scale with team size)

## Hooks for Quality Gates

- [`TeammateIdle`](/en/hooks#teammateidle): runs when teammate is about to go idle. Exit 2 → send feedback and keep working
- [`TaskCompleted`](/en/hooks#taskcompleted): runs when task is being marked complete. Exit 2 → prevent completion and send feedback

## Token Usage

Each teammate has its own context window. Token usage scales linearly with active teammates. See [agent team token costs](/en/costs#agent-team-token-costs).

## Use Case Examples

### Parallel Code Review

```text
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

### Competing Hypotheses for Debugging

```text
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

## Best Practices

- **Give enough context in the spawn prompt** (teammates don't inherit lead's conversation history)
- **Start with 3–5 teammates** (balance parallel work with coordination overhead)
- **5–6 tasks per teammate** keeps everyone productive without excessive context switching
- **Start with research/review** if new to agent teams (before parallel implementation)
- **Avoid file conflicts** — break work so each teammate owns different files
- **Monitor and steer** — don't let the team run unattended too long

## Troubleshooting

| Problem | Solution |
| ------- | -------- |
| Teammates not appearing | Press `Shift+Down` (in-process); check if task was complex enough; verify `tmux` is in PATH |
| Too many permission prompts | Pre-approve common operations in permission settings before spawning |
| Teammates stopping on errors | Give additional instructions directly or spawn replacement |
| Lead shuts down before work done | Tell it to keep going; tell it to wait for teammates before proceeding |
| Orphaned tmux sessions | `tmux ls` then `tmux kill-session -t <name>` |

## Limitations (Experimental)

- No session resumption with in-process teammates (`/resume` and `/rewind` don't restore teammates)
- Task status can lag (teammates may fail to mark tasks complete)
- Shutdown can be slow (finishes current request before shutting down)
- One team per session
- No nested teams (teammates cannot spawn their own teams)
- Lead is fixed for team's lifetime
- Permissions set at spawn (can change per-teammate after, not at spawn time)
- Split panes require tmux or iTerm2 (not VS Code terminal, Windows Terminal, or Ghostty)
