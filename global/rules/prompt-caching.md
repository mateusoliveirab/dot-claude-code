---
description: Prompt caching awareness — avoid patterns that break cache and increase cost/latency
---

# Prompt Caching

Prompt caching works by prefix matching. Any change in the prefix invalidates everything after it.

## What Breaks Cache

- Changing tools mid-session (adding/removing MCP servers, toggling tool access)
- Switching models mid-conversation (each model has its own cache)
- Timestamps or dynamic content in system prompts
- Non-deterministic tool ordering

## Safe Patterns

- Use system-reminder messages (next user turn) for dynamic updates instead of editing system prompt
- Use subagents to delegate to different models (Haiku for exploration, Opus for complex work) — subagents have their own cache
- Use `EnterPlanMode`/`ExitPlanMode` tools instead of swapping tool sets
- Use `ToolSearch` deferred loading instead of removing tools

## CLAUDE.md Implications

- Keep CLAUDE.md stable within a session — edits force cache rebuild
- Front-load static content, put dynamic content last
- Avoid `!backtick` commands that produce non-deterministic output in CLAUDE.md
