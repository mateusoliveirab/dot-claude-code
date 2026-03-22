---
url: https://x.com/trq212/status/2024574133011673516
crawled_at: 2026-03-22
tags: [claude-code, prompt-caching, performance, cost, architecture, anthropic]
---

# Lessons from Building Claude Code: Prompt Caching Is Everything

Long running agentic products like Claude Code are made feasible by prompt caching, which allows us to reuse computation from previous roundtrips and significantly decrease latency and cost.

At Claude Code, we build our entire harness around prompt caching. A high prompt cache hit rate decreases costs and helps us create more generous rate limits for our subscription plans — we run alerts on our prompt cache hit rate and declare SEVs if they're too low.

## Lay Out Your Prompt for Caching

Prompt caching works by **prefix matching** — the API caches everything from the start of the request up to each `cache_control` breakpoint. The order you put things in matters enormously; you want as many requests to share a prefix as possible.

**Static content first, dynamic content last.** For Claude Code this looks like:

1. Static system prompt & Tools (globally cached)
2. CLAUDE.MD (cached within a project)
3. Session context (cached within a session)
4. Conversation messages

This can be surprisingly fragile. Examples of things that have broken this ordering:
- Putting an in-depth timestamp in the static system prompt
- Shuffling tool order definitions non-deterministically
- Updating parameters of tools (e.g. what agents the AgentTool can call)

## Use Messages for Updates

When information in your prompt becomes out of date (e.g. the time, or a user changes a file), it may be tempting to update the prompt — but that results in a cache miss and can be quite expensive.

Consider passing updated information **via messages in the next turn** instead. In Claude Code, we add a `<system-reminder>` tag in the next user message or tool result with the updated information, which helps preserve the cache.

## Don't Change Models Mid-Session

Prompt caches are unique to models, which makes the math unintuitive.

If you're 100k tokens into a conversation with Opus and want to ask something easy, it would actually be **more expensive** to switch to Haiku than to have Opus answer — because you'd need to rebuild the prompt cache for Haiku.

If you need to switch models, the best way is with **subagents**, where Opus prepares a "handoff" message. We do this often with the Explore agents in Claude Code, which use Haiku.

## Never Add or Remove Tools Mid-Session

Changing the tool set mid-conversation is one of the most common ways to break prompt caching. Tools are part of the cached prefix — adding or removing a tool invalidates the cache for the entire conversation.

## Plan Mode — Design Around the Cache

The intuitive approach to plan mode: swap out the tool set to only include read-only tools when the user enters plan mode. But that breaks the cache.

Instead, we **keep all tools in the request at all times** and use `EnterPlanMode` and `ExitPlanMode` as tools themselves. When the user toggles plan mode, the agent gets a system message explaining the instructions — explore the codebase, don't edit files, call `ExitPlanMode` when the plan is complete. The tool definitions never change.

Bonus: because `EnterPlanMode` is a tool the model can call itself, it can autonomously enter plan mode when it detects a hard problem, without any cache break.

## Tool Search — Defer Instead of Remove

Claude Code can have dozens of MCP tools loaded. Including all of them in every request is expensive, but removing them mid-conversation breaks the cache.

**Solution: `defer_loading`**. Instead of removing tools, we send lightweight stubs — just the tool name, with `defer_loading: true` — that the model can "discover" via a `ToolSearch` tool when needed. The full tool schemas are only loaded when the model selects them. The cached prefix stays stable: the same stubs are always present in the same order.

## Forking Context — Compaction

Compaction is what happens when you run out of context window — we summarize the conversation and continue with that summary.

The naive implementation (separate API call with a different system prompt and no tools) means the cached prefix from the main conversation doesn't match at all. You pay full price for all those input tokens.

### Cache-Safe Forking

When we run compaction, we use the **exact same system prompt, user context, system context, and tool definitions** as the parent conversation. We prepend the parent's conversation messages, then append the compaction prompt as a new user message at the end.

From the API's perspective, this request looks nearly identical to the parent's last request — same prefix, same tools, same history — so the cached prefix is reused. The only new tokens are the compaction prompt itself.

This requires saving a "compaction buffer" to ensure enough room in the context window for the compact message and summary output tokens.

> Based on our learnings from Claude Code, we built compaction directly into the API, so you can apply these patterns in your own applications.

## Lessons Learned

1. **Prompt caching is a prefix match.** Any change anywhere in the prefix invalidates everything after it. Design your entire system around this constraint.
2. **Use messages instead of system prompt changes.** Inserting updates into messages preserves the cache.
3. **Don't change tools or models mid-conversation.** Use tools to model state transitions (like plan mode). Defer tool loading instead of removing tools.
4. **Monitor your cache hit rate like you monitor uptime.** Alert on cache breaks and treat them as incidents. A few percentage points of cache miss rate can dramatically affect cost and latency.
5. **Fork operations need to share the parent's prefix.** For side computations (compaction, summarization), use identical cache-safe parameters to get cache hits on the parent's prefix.

Claude Code is built around prompt caching from day one. You should do the same if you're building an agent.
