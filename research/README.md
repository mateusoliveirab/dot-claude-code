# Research

Reference material and notes for the dot-claude-code project.

## Structure

- `sources/` — Raw content: crawled docs, articles, transcripts
- `notes/` — Synthesis and analysis of sources

## Notes Index

Synthesized analysis and compiled findings (not raw sources).

| File | Description |
|------|-------------|
| `notes/claude-md-findings.md` | 60 empirical findings on CLAUDE.md best practices, context bloat, context rot, and session management (April 2026) |
| `notes/context-engineering.md` | Operational guide for Claude Code — context modes, session phases, artefact hygiene |
| `notes/claude-advisor-strategy.md` | Advisor Strategy pattern — Opus as advisor + Sonnet/Haiku as executor for near-Opus intelligence at lower cost (April 2026) |

---

## Sources Index

| File | Description |
|------|-------------|
| `cli-reference.md` | Claude Code CLI reference |
| `commands.md` | Commands documentation |
| `hooks.md` | Hooks system reference |
| `memory.md` | Memory system docs |
| `sub-agents.md` | Sub-agents documentation |
| `skills.md` | Skills documentation |
| `settings.md` | Settings reference |
| `env-vars.md` | Environment variables |
| `plugins-reference.md` | Plugins reference |
| `tools-reference.md` | Tools reference |
| `how-claude-code-works.md` | How Claude Code works |
| `overview.md` | Claude Code overview |
| `quickstart.md` | Quickstart guide |
| `setup.md` | Setup guide |
| `interactive-mode.md` | Interactive mode docs |
| `checkpointing.md` | Checkpointing docs |
| `third-party-integrations.md` | Third-party integrations |
| `terminal-config.md` | Terminal configuration |
| `changelog.md` | Claude Code changelog |
| `rtk-token-killer.md` | RTK CLI proxy — token compression for AI coding sessions (60–90% reduction) |
| `headless-programmatic.md` | Run Claude Code programmatically via Agent SDK / `-p` flag (CI/CD, scripts) |
| `scheduled-tasks.md` | Session-scoped cron: `/loop`, `CronCreate`, one-time reminders |
| `channels.md` | Push events into running session (Telegram, Discord, webhook receivers) |
| `hooks-guide.md` | Practical hooks guide: common use cases, exit codes, matchers, troubleshooting |
| `agent-teams.md` | Orchestrate multiple Claude Code sessions as a coordinated team |
| `sub-agents-guide.md` | Comprehensive subagent creation guide (frontmatter, tools, memory, examples) |
