---
url: https://x.com/bcherny/status/2017742741636321619
author: bcherny (Boris Cherny)
crawled_at: 2026-03-22
tags: [claude-code, tips, subagents, prompting, analytics, learning, terminal, bugs]
note: some threads were truncated ("Show more") — content is partial
---

# Claude Code Tips — Boris Cherny (Anthropic)

## 5. Claude Fixes Most Bugs by Itself

- Enable the **Slack MCP**, then paste a Slack bug thread into Claude and say "fix." Zero context switching required.
- Say "Go fix the failing CI tests." Don't micromanage how.
- Point Claude at docker logs to diagnose issues. *(thread truncated)*

## 6. Level Up Your Prompting

**a. Challenge Claude:**
- Say "Grill me on these changes and don't make a PR until I pass your test." Make Claude be your reviewer.
- Say "Prove to me this works" and have Claude diff behavior between main and your feature branch.

**b.** After a mediocre response *(thread truncated)*

## 7. Terminal & Environment Setup

- The team loves **Ghostty** — synchronized rendering, 24-bit color, proper unicode support.
- Use `/statusline` to customize your status bar to always show context usage and current git branch.
- *(thread truncated)*

## 8. Use Subagents

**a.** Append "use subagents" to any request where you want Claude to throw more compute at the problem.

**b.** Offload individual tasks to subagents to keep your main agent's context window clean and focused.

**c.** Route permission requests to Opus 4.5 via a hook — let it *(thread truncated)*

## 9. Use Claude for Data & Analytics

- Ask Claude Code to use the `bq` CLI to pull and analyze metrics on the fly.
- Keep a **BigQuery skill** checked into the codebase — everyone on the team uses it for analytics queries directly in Claude Code.
- "Personally, I haven't written a line [of SQL manually]" *(thread truncated)*

## 10. Learning with Claude

**a.** Enable the "Explanatory" or "Learning" output style in `/config` to have Claude explain the *why* behind its changes.

**b.** Have Claude generate a visual HTML presentation explaining unfamiliar concepts. *(thread truncated)*
